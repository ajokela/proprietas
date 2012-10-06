require 'spec_helper'

describe Country do
  it "has at least one (1) country" do
    cnt = Country.where({}).count
    cnt.should be > 0
  end
end
