json.extract! @notification, :id, :message, :employee, :created_at, :updated_at
json.employee "#{@notification.employee.surname},#{@notification.employee.name}"
