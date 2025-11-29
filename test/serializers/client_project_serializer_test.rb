require "test_helper"

class ClientProjectSerializerTest < ActiveSupport::TestCase
  def setup
    @project = client_projects(:ecommerce_project)
    @serializer = ClientProjectSerializer.new(@project)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id name role project_url start_date end_date user_id
      client_name client_website description tech_stack
      skills client_reviews
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should serialize associated skills" do
    assert @serialization.key?(:skills)
    assert @serialization[:skills].is_a?(Array)
  end

  test "should serialize associated client_reviews" do
    assert @serialization.key?(:client_reviews)
    assert @serialization[:client_reviews].is_a?(Array)
  end

  test "should include all project attributes" do
    assert_equal @project.id, @serialization[:id]
    assert_equal @project.name, @serialization[:name]
    assert_equal @project.description, @serialization[:description]
  end
end
