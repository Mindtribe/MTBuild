require 'open3'

mtbuildcli = File.join(File.dirname(__FILE__), '..', 'bin', 'mtbuild')
test_folder = File.join(File.dirname(__FILE__), 'test_projects')

describe 'mtbuild' do

  it "can build a simple project with no workspace and one application" do
    buildapp = 'SimpleProject'
    buildfile = File.join(test_folder, buildapp, 'mtbuildfile.rb')
    stdout_str, stderr_str, status = Open3.capture3("#{mtbuildcli} -f #{buildfile} --super-dry-run App1:Cfg1")
    expect(status).to eq(0)
    expect(stderr_str).to eq(
                              <<result
mkdir -p #{File.join(test_folder, buildapp, 'build/App1/Cfg1/src'.split('/'))}
mkdir -p #{File.join(test_folder, buildapp, 'build/App1/Cfg1'.split('/'))}
mkdir -p #{File.join(test_folder, buildapp, 'build/App1/Cfg1'.split('/'))}
"gcc" -std=c99 -Wall -Werror -Wextra "#{File.join(test_folder, buildapp, 'src/main.c'.split('/'))}" -MMD -c -o "#{File.join(test_folder, buildapp, 'build/App1/Cfg1/src/main.o'.split('/'))}"
"gcc" -std=c99 -Wall -Werror -Wextra "#{File.join(test_folder, buildapp, 'build/App1/Cfg1/src/main.o'.split('/'))}" -Wl,-map,"#{File.join(test_folder, buildapp, 'build/App1/Cfg1/App1-Cfg1.map'.split('/'))}" -o "#{File.join(test_folder, buildapp, 'build/App1/Cfg1/App1-Cfg1'.split('/'))}"
result
)
    expect(stdout_str).to eq(
                              <<result
built application App1:Cfg1.
result
)
  end

end
