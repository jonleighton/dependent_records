$: << File.dirname(__FILE__) + "/lib"
require "dependent_records"
ActiveRecord::Base.send :include, DependentRecords if defined?(ActiveRecord::Base)
