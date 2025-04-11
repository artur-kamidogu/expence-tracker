class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /transactions or /transactions.json
  def index
   if current_user.admin? || current_user.moderator?
     @transactions = Transaction.includes(:category, :user).order(date: :desc)
     @transactions = @transactions.where(user_id: params[:user_id]) if params[:user_id].present?
   else
     @transactions = current_user.transactions.includes(:category).order(date: :desc)

     if params[:category_id].present?
       @transactions = @transactions.where(category_id: params[:category_id])
     end

     if params[:start_date].present?
       @transactions = @transactions.where('date >= ?', params[:start_date])
     end

     if params[:end_date].present?
       @transactions = @transactions.where('date <= ?', params[:end_date])
     end

     if params[:search].present?
       search_term = "%#{params[:search]}%"
       @transactions = @transactions.where('transactions.description LIKE ?', search_term)
     end
   end
   end

    # GET /transactions/1 or /transactions/1.json
  def show
    authorize @transaction
    @transactions = Transaction.where()
      .not(id: @transaction.id)
      .where(user: current_user, category_id: @transaction.category_id)
      .joins(:category)
      .order(date: :desc)
  end

  # GET /transactions/new
  def new
    categories
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
    authorize @transaction
    categories
    unless current_user.admin?
      redirect_to transactions_path, alert: "You are not authorized to edit this transaction."
    end
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to transaction_url(@transaction), notice: "Transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update 
    unless current_user.admin?
      flash[:alert] = "You are not authorized to update transactions."
      redirect_to transactions_path
      return # Ensure the rest of the action doesn't execute for non-admins
    end

    respond_to do |format|
        if @transaction.update(transaction_params)
          format.html { redirect_to transaction_url(@transaction), notice: "Transaction was successfully updated." }
          format.json { render :show, status: :ok, location: @transaction }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    authorize @transaction
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def categories
      @categories = Category.where(user: current_user).map { |category| [category.name, category.id] }
    end

    # Only allow a list of trusted parameters through.
   def transaction_params
    allowed_params = [:amount, :description, :date, :category_id]
    allowed_params << :user_id if current_user.admin?

    params.require(:transaction).permit(*allowed_params)
  end
end
