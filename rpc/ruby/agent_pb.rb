# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: agent.proto

require 'google/protobuf'

require 'google/protobuf/empty_pb'
require 'google/protobuf/timestamp_pb'
require 'primitives_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "jiji.rpc.Tick" do
    optional :timestamp, :message, 1, "google.protobuf.Timestamp"
    repeated :values, :message, 2, "jiji.rpc.Tick.Value"
  end
  add_message "jiji.rpc.Tick.Value" do
    optional :pair, :string, 1
    optional :bid, :message, 2, "jiji.rpc.Decimal"
    optional :ask, :message, 3, "jiji.rpc.Decimal"
  end
  add_message "jiji.rpc.NextTickRequest" do
    optional :instance_id, :string, 1
    optional :tick, :message, 2, "jiji.rpc.Tick"
  end
  add_message "jiji.rpc.AgentSourceName" do
    optional :name, :string, 1
  end
  add_message "jiji.rpc.AgentSource" do
    optional :name, :string, 1
    optional :body, :string, 2
  end
  add_message "jiji.rpc.ValidationResult" do
    optional :status, :enum, 1, "jiji.rpc.ValidationResult.Status"
    optional :error, :string, 2
  end
  add_enum "jiji.rpc.ValidationResult.Status" do
    value :OK, 0
    value :ERROR, 1
  end
  add_message "jiji.rpc.AgentClasses" do
    repeated :classes, :message, 1, "jiji.rpc.AgentClasses.AgentClass"
  end
  add_message "jiji.rpc.AgentClasses.AgentClass" do
    optional :name, :string, 1
    optional :description, :string, 2
    repeated :properties, :message, 3, "jiji.rpc.AgentClasses.AgentClass.Property"
  end
  add_message "jiji.rpc.AgentClasses.AgentClass.Property" do
    optional :id, :string, 1
    optional :name, :string, 2
    optional :default, :string, 3
  end
  add_message "jiji.rpc.AgentCreationRequest" do
    optional :class_name, :string, 1
    optional :agent_name, :string, 2
    repeated :property_settings, :message, 3, "jiji.rpc.PropertySetting"
  end
  add_message "jiji.rpc.PropertySetting" do
    optional :id, :string, 1
    optional :value, :string, 2
  end
  add_message "jiji.rpc.AgentCreationResult" do
    optional :instance_id, :string, 1
  end
  add_message "jiji.rpc.ExecPostCreateRequest" do
    optional :instance_id, :string, 1
  end
  add_message "jiji.rpc.AgentDeletionRequest" do
    optional :instance_id, :string, 1
  end
  add_message "jiji.rpc.GetAgentStateRequest" do
    optional :instance_id, :string, 1
  end
  add_message "jiji.rpc.AgentState" do
    optional :state, :bytes, 1
  end
  add_message "jiji.rpc.RestoreAgentStateRequest" do
    optional :instance_id, :string, 1
    optional :state, :bytes, 2
  end
  add_message "jiji.rpc.SetAgentPropertiesRequest" do
    optional :instance_id, :string, 1
    repeated :property_settings, :message, 2, "jiji.rpc.PropertySetting"
  end
  add_message "jiji.rpc.SendActionRequest" do
    optional :instance_id, :string, 1
    optional :action_id, :string, 2
  end
  add_message "jiji.rpc.SendActionResponse" do
    optional :message, :string, 1
  end
end

module Jiji
  module Rpc
    Tick = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.Tick").msgclass
    Tick::Value = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.Tick.Value").msgclass
    NextTickRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.NextTickRequest").msgclass
    AgentSourceName = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentSourceName").msgclass
    AgentSource = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentSource").msgclass
    ValidationResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.ValidationResult").msgclass
    ValidationResult::Status = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.ValidationResult.Status").enummodule
    AgentClasses = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentClasses").msgclass
    AgentClasses::AgentClass = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentClasses.AgentClass").msgclass
    AgentClasses::AgentClass::Property = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentClasses.AgentClass.Property").msgclass
    AgentCreationRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentCreationRequest").msgclass
    PropertySetting = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.PropertySetting").msgclass
    AgentCreationResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentCreationResult").msgclass
    ExecPostCreateRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.ExecPostCreateRequest").msgclass
    AgentDeletionRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentDeletionRequest").msgclass
    GetAgentStateRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.GetAgentStateRequest").msgclass
    AgentState = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.AgentState").msgclass
    RestoreAgentStateRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.RestoreAgentStateRequest").msgclass
    SetAgentPropertiesRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.SetAgentPropertiesRequest").msgclass
    SendActionRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.SendActionRequest").msgclass
    SendActionResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("jiji.rpc.SendActionResponse").msgclass
  end
end
