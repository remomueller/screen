require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  test "should get reverse name" do
    assert_equal 'LastName, FirstName', patients(:one).reverse_name
  end

  test "should merge patients with identical MRNs" do
    patients(:two).update_column :mrn, "00000001"
    assert_difference('Patient.current.count', -1) do
      assert_difference('Call.current.count', 0) do
        assert_difference('Evaluation.current.count', 0) do
          assert_difference('Event.current.count', 0) do
            assert_difference('Mailing.current.count', 0) do
              assert_difference('Prescreen.current.count', 0) do
                assert_difference('Visit.current.count', 0) do
                  assert_equal 0, Patient.merge_dup_patients!
                end
              end
            end
          end
        end
      end
    end
  end
end
