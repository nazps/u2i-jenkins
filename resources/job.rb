# LWRP to create Jenkins job XML

actions [:create, :delete, :update]
default_action :create

# noinspection RubyStringKeysInHashInspection
callbacks = {
  branch: {
    'should be String or Array of Strings' => ->(attrs) { Array(attrs).all? { |attr| attr.is_a? String } }
  },
  matrix: {
    'can contain :combination_filter' => ->(attr) { attr.fetch(:combination_filter, '').is_a?(String) },
    'can contain :sequentially' => ->(attr) do
      !attr.key?(:sequentially) || attr[:sequentially].is_a?(TrueClass) || attr[:sequentially].is_a?(FalseClass)
    end,
    'should contain :axes' => ->(attr) do
      attr.key?(:axes) && attr[:axes].size > 0 && attr[:axes].all? { |axis| axis.is_a?(Array) }
    end
  },
  keep_builds: {
    'should contain :days key' => ->(attr) { attr[:days].is_a?(Fixnum) },
    'should contain :num key' => ->(attr) { attr[:num].is_a?(Fixnum) }
  },
  coverage: {
    'can contain :code or :total coverage' => ->(attr) { attr.is_a?(FalseClass) || attr.all? { |key, _lvl| [:code, :total].include?(key.to_sym) } },
    'coverage can have :healthy, :unhealthy and :unstable' => ->(attr) do
      attr.is_a?(FalseClass) || attr.all? do |_key, levels|
        levels.all? do |level, value|
          [:healthy, :unhealthy, :unstable].include?(level.to_sym) && value.is_a?(Fixnum)
        end
      end
    end
  },
  violations: {
    'can contain :min, :max or :unstable' => ->(attr) do
      attr.is_a?(FalseClass) || attr.all? do |level, value|
        [:min, :max, :unstable].include?(level.to_sym) && value.is_a?(Fixnum)
      end
    end,
  },
  rails_adapter: {
    'should be `mysql` or `mysql2`' => ->(attr) do
      attr.nil? || %w(mysql mysql2).include?(attr)
    end
  }
}


config = node['u2i-jenkins']['config']
plugins = config['plugins']

github_repository_regex = /^[[:word:]-]+\/[[:word:]-]+$/i
uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

attribute :repository,    kind_of: String,                  required: true, regex: github_repository_regex
attribute :branch,        kind_of: [Array, String],         required: true,                            callbacks: callbacks[:branch]
attribute :builders,      kind_of: Array,                   required: true
attribute :concurrent_build,    kind_of: [TrueClass, FalseClass], required: false, default: true

attribute :description,   kind_of: String,                  default: ''

attribute :timer_trigger, kind_of: String,                  default: 'H 22-23/1,0,0-4/1 * * *'
attribute :type,          kind_of: Symbol,                  default: :freestyle, equal_to: [:freestyle, :matrix]
attribute :lang,          kind_of: Symbol,                  default: :ruby,      equal_to: [:ruby, :java]
attribute :matrix,        kind_of: Hash,                                                               callbacks: callbacks[:matrix]
attribute :ws_cleanup,    kind_of: [TrueClass, FalseClass], default: false
attribute :keep_builds,   kind_of: Hash,                    default: config['keep_builds']['default'], callbacks: callbacks[:keep_builds]

attribute :git_recursive, kind_of: [TrueClass, FalseClass], default: false

attribute :ruby_version,  kind_of: String,                  default: node['rvm']['default_ruby']
attribute :ruby_gemset,   kind_of: String,                  default: lazy { |new_resource| new_resource.name }

attribute :coverage,      kind_of: [Hash, FalseClass],      default: plugins['coverage']['default'],   callbacks: callbacks[:coverage]

attribute :rubocop,       kind_of: [Hash, FalseClass],      default: plugins['rubocop']['default'],    callbacks: callbacks[:violations]
attribute :metric_fu,     kind_of: [TrueClass, FalseClass], default: true
attribute :brakeman,      kind_of: [TrueClass, FalseClass], default: false
attribute :rails,         kind_of: [TrueClass, FalseClass], default: false
attribute :custom_db,     kind_of: [TrueClass, FalseClass], default: false
attribute :rails_adapter, kind_of: [String, NilClass],      default: 'mysql2',                         callbacks: callbacks[:rails_adapter]
attribute :gemnasium_token, kind_of: [String, NilClass]
attribute :gemnasium_project_slugs, kind_of: Hash,         default: {}

attribute :env_inject,    kind_of: Array,                   default: []

attribute :checkstyle,    kind_of: [Hash, FalseClass],      default: plugins['checkstyle']['default'], callbacks: callbacks[:violations]
attribute :pmd,           kind_of: [Hash, FalseClass],      default: plugins['pmd']['default'],        callbacks: callbacks[:violations]
attribute :findbugs,      kind_of: [Hash, FalseClass],      default: plugins['findbugs']['default'],   callbacks: callbacks[:violations]

attribute :key,           kind_of: Hash
attribute :key_id,        kind_of: [String, NilClass],      regex: uuid_regex

attr_accessor :exists
