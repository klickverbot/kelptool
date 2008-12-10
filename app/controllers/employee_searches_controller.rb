class EmployeeSearchesController < ApplicationController
  def new
    @search_model = EmployeeSearch.new
    query = prepare_auto_completion_query( params[ :search_query ] )
    
    if query
      @search_model.contact = ContactSearch.new( :name => query )
      
      unless params[ :advanced_search ]
        if @search_model.employees.size == 1
          redirect_to @search_model.employees.first
        else
          render :action => 'create'
        end
      end
    end
    
    @search_model.contact ||= ContactSearch.new
    @search_model.skills = []
  end
  
  def create
    @search_model = EmployeeSearch.new( params[ :employee_search ] )
    @search_model.contact = ContactSearch.new( params[ :contact_search ] )
  end

  def auto_complete_for_contact_name
    query = params[ :search_query ]
    
    employees = Employee.find( :all,
      :include => :contact,
      :conditions => [ 'LOWER(contacts.name) LIKE ?', '%' + query.downcase + '%' ], 
      :order => 'contacts.name ASC',
      :limit => 10 )
    
    contacts = employees.collect &:contact
    render :inline => '<%= auto_complete_result contacts, :name, query, 25 %>',
      :locals => { :contacts => contacts, :query => query }
  end
end
