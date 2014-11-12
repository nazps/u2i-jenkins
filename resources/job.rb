# LWRP to create Jenkins job XML

actions [:create, :delete, :update]
default_action :create

state_attrs :branch, :repository

coverage_callbacks = {
  'can contain :code or :total coverage' => ->(attr) { attr.all? { |key, _levels| [:code, :total].include?(key.to_sym) } },
  'coverage can have :healthy, :unhealthy and :unstable' => ->(attr) do
    attr.all? do |_key, levels|
      levels.all? do |level, value|
        [:healthy, :unhealthy, :unstable].include?(level.to_sym) && value.is_a?(Fixnum)
      end
    end
  end
}

matrix_callbacks = {
  'can contain :combination_filter' => ->(attr) { !attr.key?(:combination_filter) || attr[:combination_filter].is_a?(String) },
  'should contain :axes' => ->(attr) do
    attr.key?(:axes) && attr[:axes].size > 0 && attr[:axes].all? { |axis| axis.is_a?(Array) }
  end
}
rubocop_callbacks = {
  'can contain :min, :max or :unstable' => ->(attr) do
    attr.all? do |level, value|
      [:min, :max, :unstable].include?(level.to_sym) && value.is_a?(Fixnum)
    end
  end,
}

keep_builds_callbacks = {
  'should contain :days key' => ->(attr) { attr[:days].is_a?(Fixnum) },
  'should contain :num key' => ->(attr) { attr[:num].is_a?(Fixnum) }
}

branch_callbacks = {
  'should be String or Array of Strings' => ->(attrs) do
    Array(attrs).all? { |attr| attr.is_a? String }
  end
}

github_repository_regex = /^[[:word:]-]+\/[[:word:]-]+$/i
config = node['u2i-jenkins']['config']
plugins = config['plugins']

uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

attribute :repository,    kind_of: String,                  required: true, regex: github_repository_regex
attribute :branch,        kind_of: [Array, String],         required: true,
          callbacks: branch_callbacks
attribute :builders,      kind_of: Array,                   required: true

attribute :type,          kind_of: Symbol,                  default: :ruby, equal_to: [:ruby, :ruby_matrix]
attribute :matrix,        kind_of: Hash,
          callbacks: matrix_callbacks
attribute :keep_builds,   kind_of: Hash,                    default: config['keep_builds']['default'],
          callbacks: keep_builds_callbacks

attribute :git_recursive, kind_of: [TrueClass, FalseClass], default: false

attribute :ruby_version,  kind_of: String,                  default: node['rvm']['default_ruby']
attribute :ruby_gemset,   kind_of: String,                  default: lazy { |new_resource| new_resource.name }

attribute :coverage,      kind_of: [Hash, NilClass],        default: plugins['coverage']['default'],
          callbacks: coverage_callbacks

attribute :rubocop,       kind_of: Hash,                    default: plugins['rubocop']['default'],
          callbacks: rubocop_callbacks
attribute :metric_fu,     kind_of: [TrueClass, FalseClass], default: true
attribute :brakeman,      kind_of: [TrueClass, FalseClass], default: false
attribute :rails,         kind_of: [TrueClass, FalseClass], default: false

attribute :key,           kind_of: [String, NilClass]
attribute :key_id,        kind_of: [String, NilClass],      regex: uuid_regex

attr_accessor :exists
