defmodule JsonScrubTest do
  use ExUnit.Case
  doctest JsonScrub

  test "scrubbed json file comparison with standard" do
    {_, standard} = JsonScrubHelpers.open_file("./test_files/json_scrub_test_standard.json")
    JsonScrub.json_from_file("./test_files/json_scrub_test.json")
    {_, scrubbed} = JsonScrubHelpers.open_file("./test_files/json_scrub_test_scrubbed.json")
    assert scrubbed == standard
  end

  test "scrubbed json file comparison with orignal" do
    {_, original} = JsonScrubHelpers.open_file("./test_files/json_scrub_test.json")
    JsonScrub.json_from_file("./test_files/json_scrub_test.json")
    {_, scrubbed} = JsonScrubHelpers.open_file("./test_files/json_scrub_test_scrubbed.json")
    refute scrubbed == original
  end
end
