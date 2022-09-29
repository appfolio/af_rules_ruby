namespace :webpacker do
  task :check_npm do
    begin
      npm_version = `npm --version`
      raise Errno::ENOENT if npm_version.blank?
    end

    task :npm_install do
      system 'npm install'
    end
  end
end
