# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :rails_llm_agents do |t|
    t.string :title, default: "New Agent"
    t.text :data
    t.timestamps
  end
end
