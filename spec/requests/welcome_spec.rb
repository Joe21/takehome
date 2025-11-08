require 'rails_helper'

RSpec.describe "Welcome", type: :request do
  describe "GET /index" do
    subject { get root_path }

    it "returns a successful response" do
      subject
      expect(response).to have_http_status(:ok)
    end
  end
end
