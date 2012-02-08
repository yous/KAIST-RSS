module ApplicationHelper
  def mobile_user_agent?
    agent = request.env["HTTP_USER_AGENT"]
    agent and (agent[/mobile/i] or agent[/iphone/i] or agent[/android/i] or agent[/blackberry/i])
  end
end
