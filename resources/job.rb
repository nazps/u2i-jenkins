# LWRP to create Jenkins job XML
#
# Example:
#
#     u2i_jenkins_job "project1" do
#         rubocop {
#             'enabled' => true,
#             'min' => 10,
#             'max' => 20,
#             'unstable' => 30
#           }
#
#         branch 'master'
#         branches 'master'
#     end


actions [:create, :delete, :update]

default_action :create


state_attrs :branch,
            :repository

rcov_metric_callbacks = {
  'should contain :total_coverage' =>
    ->(p) { p.key?(:total_coverage) },
  'should contain :code_coverage' =>
    ->(p) { p.key?(:code_coverage) },
  'each coverage should have :healthy, :unhealthy and :unstable' =>
    ->(p) do
      p.each do |coverage|
        coverage.key?(:healthy) && p.key?(:unhealthy) && p.key?(:unstable)
      end
    end
}

keep_builds_callbacks = {
  'should contain :days key' =>
    ->(p) { p.key?(:days) },
  'should contain :num key' =>
    ->(p) { p.key?(:num) }
}

attribute :pull_request?, kind_of?: [TrueClass, FalseClass],       default: false
attribute :simplecov,     kind_of?: [TrueClass, FalseClass],       default: true
attribute :rcov,          kind_of?: [TrueClass, FalseClass],       default: true
attribute :rcov_metric,   kind_of?: Hash,
          default: {
            total_coverage: {healthy: 80, unhealthy: 0, unstable: 0},
            code_coverage: {healthy: 80, unhealthy: 70, unstable: 50}
          },
          callbacks: rcov_metric_callbacks

attribute :rubocop,       kind_of?: [TrueClass, FalseClass, Hash], default: true
attribute :key,           kind_of?: [String, NilClass]
attribute :repository,    kind_of?: String,                        required: true,
          regex: /^[[:word:]-]+\/[[:word:]-]+$/
attribute :branch,        kind_of?: String,                        required: true
attribute :type,          kind_of?: String,                        required: true,
          equal_to: %w(ruby ruby-matrix)
attribute :matrix_axes,   kind_of?: Hash

attribute :keep_builds,   kind_of?: Hash, default: {days: 60, num: 50},
          callbacks: keep_builds_callbacks
attribute :recursive_submodules, kind_of?: [TrueClass, FalseClass], default: true
attribute :tracking_submodules,  kind_of?: [TrueClass, FalseClass], default: true
