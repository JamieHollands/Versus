defmodule ScrubTest do
  use ExUnit.Case
  doctest Scrub

  @map %{level1:
  %{level2:
    %{level3:
      %{level4:
        %{level5:
          %{name: "jamie", username: "testing_scrub", password: "ScrubTest1234", email: "maps_that_are@deeplynested.com"}}}}}}

  @scrubbed_map %{level1:
    %{level2:
      %{level3:
        %{level4:
          %{level5:
            %{name: "******", username: "******", password: "******", email: "******@deeplynested.com"}}}}}}

@map_list %{level1:
%{level2:
  %{level3:
    %{level4:
      %{level5:
        %{list: [name: "jamie", username: "testing_scrub", password: "ScrubTest1234", email: "maps_that_are@deeplynested.com"]}}}}}}

@scrubbed_map_list %{level1:
%{level2:
  %{level3:
    %{level4:
      %{level5: %{list: [email: "******@deeplynested.com", name: "******", password: "******", username: "******"]}}}}}}


  @keyword_list [level1:
  [level2:
    [level3:
      [level4:
        [level5:
          [name: "jamie", username: "jamie", password: "secret", email: "jamie_hollands@uri.edu"]]]]]]

@scrubbed_keyword_list [level1: [
  level2:
    [level3:
      [level4:
        [level5:
          [email: "******@uri.edu", name: "******", password: "******", username: "******"]]]]]]

@keyword_list_map [level1:
[level2:
  [level3:
    [level4:
      [level5:
        [scrub:
          %{name: "jamie", username: "jamie", password: "secret", email: "jamie_hollands@uri.edu"}]]]]]]

@scrubbed_keyword_list_map [level1:
[level2:
  [level3:
    [level4:
      [level5:
        [scrub: %{email: "******@uri.edu", name: "******", password: "******", username: "******"}]]]]]]



  test "deeply nested map success" do
    assert @scrubbed_map == Scrub.scrub(@map)
  end

  test "deeply nested map failure" do
    refute @map == Scrub.scrub(@map)
  end

  test "deeply nested map with a nested list success" do
    assert @scrubbed_map_list == Scrub.scrub(@map_list)
  end

  test "deeply nested map with a nest list failure" do
    refute @map_list == Scrub.scrub(@map_list)
  end

  test "deeply nested keyworld list success" do
    assert @scrubbed_keyword_list == Scrub.scrub(@keyword_list)
  end

  test "deeply nested keyword list failure" do
    refute @keyword_list == Scrub.scrub(@keyword_list)
  end

  test "deeply nested keyworld list with a nested map success" do
    assert @scrubbed_keyword_list_map == Scrub.scrub(@keyword_list_map)
  end

  test "deeply nested keyword list with a nested map failure" do
    refute @keyword_list_map == Scrub.scrub(@keyword_list_map)
  end

end
