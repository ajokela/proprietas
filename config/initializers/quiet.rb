# Stop sharing so much!
ActionController::Base.class_eval do
  def add_instance_variables_to_assigns() end
end

# Stop caring so much!
ActionView::Base.class_eval do
  def assign_variables_from_controller() end
end