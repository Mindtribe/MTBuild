require 'open3'

mtbuildcli = File.join(File.dirname(__FILE__), '..', 'bin', 'mtbuild')
test_folder = File.join(File.dirname(__FILE__), 'test_projects')

describe 'mtbuild' do

  it "can build a simple project with no workspace and one application" do
    project = 'SimpleProject'
    project_folder = File.join(test_folder, project)
    Dir.chdir(project_folder) {
      stdout_str, stderr_str, status = Open3.capture3("#{mtbuildcli} --super-dry-run App1:Cfg1")
      expect(status).to eq(0)
      expect(stderr_str.gsub(project_folder,'')).to eq(
                                                        <<result
mkdir -p /build/App1/Cfg1/src
mkdir -p /build/App1/Cfg1
mkdir -p /build/App1/Cfg1
"gcc" -std=c99 -Wall -Werror -Wextra "/src/main.c" -MMD -c -o "/build/App1/Cfg1/src/main.o"
"gcc" -std=c99 -Wall -Werror -Wextra "/build/App1/Cfg1/src/main.o" -Wl,-map,"/build/App1/Cfg1/App1-Cfg1.map" -o "/build/App1/Cfg1/App1-Cfg1"
result
)
      expect(stdout_str).to eq(
                                <<result
built application App1:Cfg1.
result
)
    }
  end

  it "can build a project with a workspace, a library, and multiple apps" do
    project = 'LibraryWithMultipleApps'
    project_folder = File.join(test_folder, project)
    Dir.chdir(project_folder) {
      stdout_str, stderr_str, status = Open3.capture3("#{mtbuildcli} --super-dry-run")
      expect(status).to eq(0)
      expect(stderr_str.gsub(project_folder,'')).to eq(
                                                        <<result
mkdir -p /build/LibWithApps/Library/Cfg1/src
mkdir -p /build/LibWithApps/Library/Cfg1
mkdir -p /build/LibWithApps/Library/Cfg1
"gcc" -DCfg1 -std=c99 -Wall -Werror -Wextra "/Library/src/Library.c" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/Library/Cfg1/src/Library.o"
"gcc" -DCfg1 -std=c99 -Wall -Werror -Wextra "/Library/src/LibraryFoo.c" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/Library/Cfg1/src/LibraryFoo.o"
"ar" rcs "/build/LibWithApps/Library/Cfg1/libLibWithApps:Library-Cfg1.a"  "/build/LibWithApps/Library/Cfg1/src/Library.o" "/build/LibWithApps/Library/Cfg1/src/LibraryFoo.o"
mkdir -p /build/LibWithApps/Library/Test/src
mkdir -p /build/LibWithApps/Library/Test
mkdir -p /build/LibWithApps/Library/Test
"gcc" -Dgcc -std=c99 -Wall -Werror -Wextra "/Library/src/Library.c" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/Library/Test/src/Library.o"
"gcc" -Dgcc -std=c99 -Wall -Werror -Wextra "/Library/src/LibraryFoo.c" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/Library/Test/src/LibraryFoo.o"
"ar" rcs "/build/LibWithApps/Library/Test/libLibWithApps:Library-Test.a"  "/build/LibWithApps/Library/Test/src/Library.o" "/build/LibWithApps/Library/Test/src/LibraryFoo.o"
mkdir -p /build/LibWithApps/LibraryTest/Test/src
mkdir -p /build/LibWithApps/LibraryTest/Test
mkdir -p /build/LibWithApps/LibraryTest/Test
"gcc" -Dgcc -Wall -Werror -Wextra "/Library/src/Library_test.cpp" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/LibraryTest/Test/src/Library_test.o"
"gcc" -Dgcc -std=c99 -Wall -Werror -Wextra -I"/Library/src" -I"/Library/include" "/build/LibWithApps/LibraryTest/Test/src/Library_test.o" "/build/LibWithApps/Library/Test/libLibWithApps:Library-Test.a" -Wl,-map,"/build/LibWithApps/LibraryTest/Test/LibWithApps:LibraryTest-Test.map" -o "/build/LibWithApps/LibraryTest/Test/LibWithApps:LibraryTest-Test"
"/build/LibWithApps/LibraryTest/Test/LibWithApps:LibraryTest-Test"
mkdir -p /build/LibWithApps/App1/Cfg1/
mkdir -p /build/LibWithApps/App1/Cfg1
"gcc" -std=c99 -Wall -Werror -Wextra "/Apps/App1/main.c" -I"/Library/include" -MMD -c -o "/build/LibWithApps/App1/Cfg1/main.o"
"gcc" -std=c99 -Wall -Werror -Wextra -I"/Library/include" "/build/LibWithApps/App1/Cfg1/main.o" "/build/LibWithApps/Library/Cfg1/libLibWithApps:Library-Cfg1.a" -Wl,-map,"/build/LibWithApps/App1/Cfg1/LibWithApps:App1-Cfg1.map" -o "/build/LibWithApps/App1/Cfg1/LibWithApps:App1-Cfg1"
mkdir -p /build/LibWithApps/Library/Cfg2/src
mkdir -p /build/LibWithApps/Library/Cfg2
mkdir -p /build/LibWithApps/Library/Cfg2
"gcc" -DCfg2 -std=c99 -Wall -Werror -Wextra "/Library/src/Library.c" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/Library/Cfg2/src/Library.o"
"gcc" -DCfg2 -std=c99 -Wall -Werror -Wextra "/Library/src/LibraryFoo.c" -I"/Library/src" -I"/Library/include" -MMD -c -o "/build/LibWithApps/Library/Cfg2/src/LibraryFoo.o"
"ar" rcs "/build/LibWithApps/Library/Cfg2/libLibWithApps:Library-Cfg2.a"  "/build/LibWithApps/Library/Cfg2/src/Library.o" "/build/LibWithApps/Library/Cfg2/src/LibraryFoo.o"
mkdir -p /build/LibWithApps/App1/Cfg2/
mkdir -p /build/LibWithApps/App1/Cfg2
"gcc" -std=c99 -Wall -Werror -Wextra "/Apps/App1/main.c" -I"/Library/include" -MMD -c -o "/build/LibWithApps/App1/Cfg2/main.o"
"gcc" -std=c99 -Wall -Werror -Wextra -I"/Library/include" "/build/LibWithApps/App1/Cfg2/main.o" "/build/LibWithApps/Library/Cfg2/libLibWithApps:Library-Cfg2.a" -Wl,-map,"/build/LibWithApps/App1/Cfg2/LibWithApps:App1-Cfg2.map" -o "/build/LibWithApps/App1/Cfg2/LibWithApps:App1-Cfg2"
mkdir -p /build/LibWithApps/App2/Cfg1/
mkdir -p /build/LibWithApps/App2/Cfg1
"gcc" -std=c99 -Wall -Werror -Wextra "/Apps/App2/main.c" -I"/Library/include" -MMD -c -o "/build/LibWithApps/App2/Cfg1/main.o"
"gcc" -std=c99 -Wall -Werror -Wextra -I"/Library/include" "/build/LibWithApps/App2/Cfg1/main.o" "/build/LibWithApps/Library/Cfg1/libLibWithApps:Library-Cfg1.a" -Wl,-map,"/build/LibWithApps/App2/Cfg1/LibWithApps:App2-Cfg1.map" -o "/build/LibWithApps/App2/Cfg1/LibWithApps:App2-Cfg1"
mkdir -p /build/LibWithApps/App2/Cfg2/
mkdir -p /build/LibWithApps/App2/Cfg2
"gcc" -std=c99 -Wall -Werror -Wextra "/Apps/App2/main.c" -I"/Library/include" -MMD -c -o "/build/LibWithApps/App2/Cfg2/main.o"
"gcc" -std=c99 -Wall -Werror -Wextra -I"/Library/include" "/build/LibWithApps/App2/Cfg2/main.o" "/build/LibWithApps/Library/Cfg2/libLibWithApps:Library-Cfg2.a" -Wl,-map,"/build/LibWithApps/App2/Cfg2/LibWithApps:App2-Cfg2.map" -o "/build/LibWithApps/App2/Cfg2/LibWithApps:App2-Cfg2"
result
)
      expect(stdout_str).to eq(
                                <<result
built library LibWithApps:Library:Cfg1.
built library LibWithApps:Library:Test.
built test application LibWithApps:LibraryTest:Test.
ran test application LibWithApps:LibraryTest:Test.
built application LibWithApps:App1:Cfg1.
built library LibWithApps:Library:Cfg2.
built application LibWithApps:App1:Cfg2.
built application LibWithApps:App2:Cfg1.
built application LibWithApps:App2:Cfg2.
result
)
    }
  end

end
