module DependentRecords
  def dependent_records
    unless @dependent_records
      associations = self.class.reflect_on_all_associations.find_all { |assoc| [:has_many, :has_and_belongs_to_many].include?(assoc.macro) }
      through_associations = associations.find_all { |assoc| !assoc.options[:through].nil? }
      join_association_names = through_associations.map { |assoc| assoc.options[:through] }
      
      @dependent_records = {}
      associations.each do |assoc|
        if assoc.options[:dependent] == :destroy && !join_association_names.include?(assoc.name)
          @dependent_records[assoc.class_name.underscore] = send(assoc.name) unless send(assoc.name).blank?
        end
      end
    end
    @dependent_records
  end
end
