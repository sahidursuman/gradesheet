# Contains the grading scale data used for each course.
class GradingScale < ActiveRecord::Base
	before_destroy	:ensure_no_children
  after_update  :save_ranges
  
	has_many	:courses
	has_many  :grade_ranges, :dependent => :destroy
	
	validates_length_of		  :name, :within => 1..20
	validates_uniqueness_of :name, :case_sensitive => false
	validates_associated    :grade_ranges


  def new_range_attributes=(range_attributes)
    range_attributes.each do |attributes|
      grade_ranges.build(attributes)
    end
  end
  
  def existing_range_attributes=(range_attributes)
    grade_ranges.reject(&:new_record?).each do |range|
      attributes = range_attributes[range.id.to_s]
      if attributes
        range.attributes = attributes
      else
        grade_ranges.delete(range)
      end
    end
  end


private		

  def save_ranges
    grade_ranges.each do |range|
        range.save(false)
    end
  end

  # Ensure that the user does not delete a record without first cleaning up
  # any records that use it.  This could cause a cascading effect, wiping out
  # more data than expected.	
	def ensure_no_children
		unless self.courses.empty?
			self.errors.add_to_base "You must remove all Courses before deleting."
			raise ActiveRecord::Rollback
		end
	end

end
