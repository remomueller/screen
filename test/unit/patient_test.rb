require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  test "should get reverse name" do
    assert_equal 'LastName, FirstName', patients(:one).reverse_name
  end
end
