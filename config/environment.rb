require 'pathname'
$LOAD_PATH << Pathname(__dir__).join('..', 'lib')
require 'sequel'
require 'config'
require 'server'

begin
  require 'dotenv'
  Dotenv.load
rescue LoadError
end
