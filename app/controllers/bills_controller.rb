class BillsController < ApplicationController
  before_filter :get_rental_action, :except => [ :index, :generate_serial_number ]
  
  def index
    flash.keep
    redirect_to rental_action_path( params[ :rental_action_id ] )
  end
  
  def show
    @bill = @rental_action.bills.find( params[ :id ] )
    
    unless @bill.db_file
      flash[ :error ] = 'Zu dieser Rechnung ist noch keine Datei gespeichert!'
      redirect_to :action => 'edit'
    else
      unless params[ :format ] == @bill.extension
        redirect_to :action => 'show', :format => @bill.extension
      else
        send_data( @bill.current_data, :filename => @bill.reference + '.' + @bill.extension, :type => @bill.content_type )
      end
    end
  end
  
  def new
    @bill = Bill.new
    @bill.rental_action = @rental_action
    
    @types = BillType.all
  end
  
  def new_step_2
    @bill = Bill.new
    @bill.rental_action = @rental_action
    
    key = BillType.find_by_name( params[ :bill_type ] ).key
    
    unless key
      flash[ :error ] = 'Wählen Sie die Art der Rechnung.'
      redirect_to :action => 'new'
    end
    
    @bill.bill_type = key
  end
  
  def create
    @bill = Bill.new( params[ :bill ] )
    @bill.rental_action = @rental_action
    
    if @bill.save
      flash[ :notice ] = 'Rechnung erzeugt. Laden Sie jetzt die Datei für die Rechnung hoch.'
      redirect_to :action => 'edit'
    else
      render :action => 'new_step_2'
    end
  end
  
  def edit
    @bill = @rental_action.bills.find( params[ :id ] )
    respond_to do |format|
      format.html
      format.xlsx do
        send_data( generate_document, :filename => "#{@bill.reference}.xlsx", :type => Mime::XLSX.to_s )
      end
    end
  end
  
  def update
    @bill = @rental_action.bills.find( params[ :id ] )
    
    if @bill.update_attributes( params[ :bill ] )
      flash[ :notice ] = 'Rechnung gespeichert.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @bill = Bill.find( params[ :id ] )
    @bill.destroy
    flash[ :notice ] = 'Rechnung gelöscht.'
    redirect_to :action => 'index'
  end
  
  def generate_serial_number
    maximum = Bill.maximum( :serial_number, :conditions => [ 'type_key = ?', params[ :type_key ] ] ) || 0
    @serial_number = maximum + 1
  end
  
  private
    def get_rental_action
      @rental_action = RentalAction.find( params[ :rental_action_id ] )
    end
    
    def generate_document
      ''
    end
end
