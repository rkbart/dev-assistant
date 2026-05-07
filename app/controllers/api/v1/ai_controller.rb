class Api::V1::AiController < ApplicationController
  def ask
    prompt = params[:prompt]

    result = LlmService.ask(prompt)

    render json: {
      response: result["response"]
    }
  end
end