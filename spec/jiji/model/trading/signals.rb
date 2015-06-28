module Signals
  #===一定期間のレートデータを元に値を算出するシグナルの基底クラス
  class RangeSignal

    include Signals
    #====コンストラクタ
    # range:: 集計期間
    def initialize(range = 25)
      @data  = [] # レートを記録するバッファ
      @range = range
    end
    #====次のデータを受け取って指標を返します。
    # data:: 次のデータ
    # 戻り値:: 指標。十分なデータが蓄積されていない場合nil
    def next_data(data)
      # バッファのデータを更新
      @data.push data
      @data.shift if @data.length > @range

      # バッファサイズが十分でなければ、nilを返す。
      return nil if @data.length != @range

      # 算出
      calculate(@data)
    end
    #
    def calculate(data); end #:nodoc:
    # 集計期間
    attr_reader :range

  end

  #===移動平均
  class MovingAverage < RangeSignal

    def calculate(data) #:nodoc:
      ma(data)
    end

  end

  #===加重移動平均
  class WeightedMovingAverage < RangeSignal

    def calculate(data) #:nodoc:
      wma(data)
    end

  end

  #===指数移動平均
  class ExponentialMovingAverage < RangeSignal

    #====コンストラクタ
    # range:: 集計期間
    # smoothing_coefficient:: 平滑化係数
    def initialize(range = 25, smoothing_coefficient = 0.1)
      super(range)
      @sc = smoothing_coefficient
    end

    def calculate(data) #:nodoc:
      ema(data, @sc)
    end

  end

  #===ボリンジャーバンド
  class BollingerBands < RangeSignal

    #====コンストラクタ
    # range:: 集計期間
    # pivot:: ピボット
    def initialize(range = 25, pivot = [0, 1, 2], &block)
      super(range)
      @pivot = pivot
      @block = block
    end

    def calculate(data) #:nodoc:
      bollinger_bands(data, @pivot, &@block)
    end

  end

  #===傾き
  class Momentum < RangeSignal

    def calculate(data) #:nodoc:
      momentum(data)
    end

  end

  #===傾き(最小二乗法を利用)
  class Vector < RangeSignal

    def calculate(data)
      vector(data)
    end

  end

  #===MACD
  class MACD < RangeSignal

    #====コンストラクタ
    # short_range:: 短期EMAの集計期間
    # long_range:: 長期EMAの集計期間
    # signal_range:: シグナルの集計期間
    # smoothing_coefficient:: 平滑化係数
    def initialize(short_range = 12, long_range = 26,
        signal_range = 9, smoothing_coefficient = 0.1)
      fail 'illegal arguments.' if short_range > long_range
      super(long_range)
      @short_range = short_range
      @smoothing_coefficient = smoothing_coefficient
      @signal = ExponentialMovingAverage.new(
        signal_range, smoothing_coefficient)
    end

    def next_data(data) #:nodoc:
      macd = super
      return nil unless macd
      signal = @signal.next_data(macd)
      return nil unless signal
      { macd: macd, signal: signal }
    end

    def calculate(data) #:nodoc:
      macd(data, @short_range, range, @smoothing_coefficient)
    end

  end

  #===RSI
  class RSI < RangeSignal

    #====コンストラクタ
    # range:: 集計期間
    def initialize(range = 14)
      super(range)
    end

    def calculate(data) #:nodoc:
      rsi(data)
    end

  end

  #===DMI
  class DMI < RangeSignal

    #====コンストラクタ
    # range:: 集計期間
    def initialize(range = 14)
      super(range)
      @dxs = []
    end

    def calculate(data) #:nodoc:
      dmi = dmi(data)
      return nil unless dmi
      @dxs.push dmi[:dx]
      @dxs.shift if @dxs.length > range
      return nil if @dxs.length != range
      dmi[:adx] = ma(@dxs)
      dmi
    end

  end

  #===ROC
  class ROC < RangeSignal

    #====コンストラクタ
    # range:: 集計期間
    def initialize(range = 14)
      super(range)
    end

    def calculate(data) #:nodoc:
      roc(data)
    end

  end

  module_function

  #===移動平均値を計算します。
  # data:: 値の配列。
  # 戻り値:: 移動平均値
  def ma(data)
    total = data.reduce(:+)
    total / data.length
  end

  #===加重移動平均値を計算します。
  # data:: 値の配列。
  # 戻り値:: 加重移動平均値
  def wma(data)
    weight = 0
    total = data.reduce(0.0) do |t, s|
      t + s * (weight += 1)
    end
    total / (data.length * (data.length + 1) / 2)
  end

  #===指数移動平均値を計算します。
  # data:: 値の配列。
  # smoothing_coefficient:: 平滑化係数
  # 戻り値:: 加重移動平均値
  def ema(data, smoothing_coefficient = 0.1)
    data[1..-1].reduce(data[0]) do|t, s|
      t + smoothing_coefficient * (s - t)
    end
  end

  #
  #===ボリンジャーバンドを計算します。
  #
  # +2σ＝移動平均＋標準偏差×2
  # +σ＝移動平均＋標準偏差
  # -σ＝移動平均-標準偏差
  # -2σ＝移動平均-標準偏差×2
  # 標準偏差＝√((各値-値の期間中平均値)の2乗を期間分全部加えたもの)/ 期間
  # (√は式全体にかかる)
  #
  # data:: 値の配列
  # pivot:: 標準偏差の倍数。初期値[0,1,2]
  # block:: 移動平均を算出するロジック。指定がなければ移動平均を使う。
  # 戻り値:: ボリンジャーバンドの各値の配列。例)  [+2σ, +1σ, TP, -1σ, -2σ]
  #
  def bollinger_bands(data, pivot = [0, 1, 2], &block)
    ma = block_given? ? yield(data) : ma(data)
    total = data.reduce(0.0) do|t, s|
      t + (s - ma)**2
    end
    sd = Math.sqrt(total / data.length)
    res = []
    pivot.each do |r|
      res.unshift(ma + sd * r)
      res.push(ma + sd * r * -1) if r != 0
    end
    res
  end

  #===一定期間の値の傾きを計算します。
  # data::  値の配列
  # 戻り値:: 傾き。0より大きければ上向き。小さければ下向き。
  def momentum(data)
    (data.last - data.first) / data.length
  end

  #===最小二乗法で、一定期間の値の傾きを計算します。
  # data::  値の配列
  # 戻り値:: 傾き。0より大きければ上向き。小さければ下向き。
  def vector(data)
    # 最小二乗法を使う。
    total = { x: 0.0, y: 0.0, xx: 0.0, xy: 0.0, yy: 0.0 }
    data.each_index do|i|
      total[:x] += i
      total[:y] += data[i]
      total[:xx] += i * i
      total[:xy] += i * data[i]
      total[:yy] += data[i] * data[i]
    end
    n = data.length
    d = total[:xy]
    c = total[:y]
    e = total[:x]
    b = total[:xx]
    (n * d - c * e) / (n * b - e * e)
  end

  #===MACDを計算します。
  # MACD = 短期(short_range日)の指数移動平均 - 長期(long_range日)の指数移動平均
  # data::  値の配列
  # smoothing_coefficient:: 平滑化係数
  # 戻り値:: macd値
  def macd(data, short_range, long_range, smoothing_coefficient)
    ema(data[short_range * -1..-1], smoothing_coefficient) \
      - ema(data[long_range * -1..-1], smoothing_coefficient)
  end

  #===RSIを計算します。
  # RSI = n日間の値上がり幅合計 / (n日間の値上がり幅合計 + n日間の値下がり幅合計) * 100
  # nとして、14や9を使うのが、一般的。30以下では売られすぎ70以上では買われすぎの水準。
  #
  # data::  値の配列
  # 戻り値:: RSI値
  def rsi(data)
    prev = nil
    tmp = data.each_with_object([0.0, 0.0]) do|i, r|
      r[i > prev ? 0 : 1] += (i - prev).abs if prev
      prev = i
    end
    (tmp[0] + tmp[1]) == 0 ? 0.0 : tmp[0] / (tmp[0] + tmp[1]) * 100
  end

  #===DMIを計算します。
  #
  # 高値更新  ...  前日高値より当日高値が高かった時その差
  # 安値更新  ...  前日安値より当日安値が安かった時その差
  # DM        ...  高値更新が安値更新より大きかった時高値更新の値。逆の場合は０
  # DM        ...  安値更新が高値更新より大きかった時安値更新の値。逆の場合は０
  # TR        ...  次の３つの中で一番大きいもの
  #                  当日高値-当日安値
  #                  当日高値-前日終値
  #                  前日終値-当日安値
  # AV(+DM)   ...  +DMのn日間移動平均値
  # AV(-DM)   ...  -DMのn日間移動平均値
  # AV(TR)    ...  TRのn日間移動平均値
  # +DI       ...  AV(+DM)/AV(TR)
  # -DI       ...  AV(-DM)/AV(TR)
  # DX        ...  (+DIと-DIの差額) / (+DIと-DIの合計)
  # ADX       ...  DXのn日平均値
  #
  # data::  値の配列(4本値を指定すること!)
  # 戻り値:: {:pdi=pdi, :mdi=mdi, :dx=dx }
  def dmi(data)
    prev = nil
    tmp = data.each_with_object([[], [], []]) do|i, r|
      if prev
        dm = _dmi(i, prev)
        r[0] << dm[0] # TR
        r[1] << dm[1] # +DM
        r[2] << dm[2] # -DM
      end
      prev = i
    end
    atr = ma(tmp[0])
    pdi = ma(tmp[1]) / atr * 100
    mdi = ma(tmp[2]) / atr * 100
    dx  = (pdi - mdi).abs / (pdi + mdi)  * 100
    { pdi: pdi, mdi: mdi, dx: dx }
  end

  # TR,+DM,-DMを計算します。
  # 戻り値:: [ tr, +DM, -DM ]
  def _dmi(rate, rate_prev) #:nodoc:
    pdm = rate.max > rate_prev.max ? rate.max - rate_prev.max : 0
    mdm = rate.min < rate_prev.min ? rate_prev.min - rate.min : 0

    if  pdm > mdm
      mdm = 0
    elsif  pdm < mdm
      pdm = 0
    end

    a = rate.max - rate.min
    b = rate.max - rate_prev.end
    c = rate_prev.end - rate.min
    tr = [a, b, c].max

    [tr, pdm, mdm]
  end

  #===ROCを計算します。
  # Rate of Change。変化率。正なら上げトレンド、負なら下げトレンド。
  #
  # data::  値の配列
  # 戻り値:: 値
  def roc(data)
    (data.first - data.last) / data.last * 100
  end
end