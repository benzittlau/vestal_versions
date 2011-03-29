module VestalVersions
  # Allows version creation to occur conditionally based on given <tt>:if</tt> and/or
  # <tt>:unless</tt> options.
  module Deletion
    extend ActiveSupport::Concern

    included do
      before_destroy :create_destroyed_version, :if => :create_delete_version?
    end

    # Class methods on ActiveRecord::Base
    module ClassMethods
      # After the original +prepare_versioned_options+ method cleans the given options, this alias
      # also extracts the <tt>:depedent</tt> if it set to <tt>:tracking</tt>
      # TODO: clean this up by including it in the function instead of overwriting it
      def prepare_versioned_options(options)
        result = super(options)
        if result[:dependent] == :tracking
          self.vestal_versions_options[:track_destroy] = true
          options.delete(:dependent)
        end

        result
      end
    end

    module InstanceMethods
      private

      def create_delete_version?
        vestal_versions_options[:track_destroy]
      end

      def create_destroyed_version
        attributes_for_version_creation = {
          :action => :destroy,
          :modifications => attributes, 
          :number => last_version + 1, 
          :tag => 'deleted'}
          
        versions.create(attributes_for_version_creation)
      end
    end
  end
end
