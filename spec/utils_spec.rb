require 'mtbuild/utils'

describe MTBuild::Utils, '#path_difference' do
  it "returns the difference between a root path and a subpath" do
    root_path = '/this/is/a/path'
    sub_path  = '/this/is/a/path/with/a/subpath'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('with/a/subpath')
  end

  it "returns the difference between two paths with mixed trailing slashes" do
    root_path = '/this/is/a/path/'
    sub_path  = '/this/is/a/path/with/a/subpath'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('with/a/subpath')

    root_path = '/this/is/a/path'
    sub_path  = '/this/is/a/path/with/a/subpath/'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('with/a/subpath')

    root_path = '/this/is/a/path/'
    sub_path  = '/this/is/a/path/with/a/subpath/'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('with/a/subpath')
  end

  it "returns nil if one path does not contain the other" do
    root_path = '/this/is/a/path'
    sub_path  = '/this/is/a/different/path'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to be_nil

    root_path = '/this/is/a/path'
    sub_path  = '/this/is/a/path/../another'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to be_nil

    root_path = '/this/is/a/path'
    sub_path  = '/this/is'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to be_nil
  end

  it "returns empty if the paths are equal" do
    root_path = '/this/is/a/path'
    sub_path  = '/this/is/a/path'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('')

    root_path = '/this/is/a/path/'
    sub_path  = '/this/is/a/path/'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('')

    root_path = '/this/is/a/path/'
    sub_path  = '/this/is/a/path'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('')

    root_path = '/this/is/a/path'
    sub_path  = '/this/is/a/path/'
    expect(MTBuild::Utils::path_difference(root_path, sub_path)).to eq('')
  end
end
