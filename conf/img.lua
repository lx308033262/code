--[[ngx.say('hello');
ngx.say(ngx.var.request_filepath);
ngx.say(ngx.var.width);
ngx.say(ngx.var.height);
]]
--判断文件是否存在 不存在先从tfs中下载源文件
download_command = string.format("cd /usr/local/nginx/tfsimg ;[ -f " .. ngx.var.request_filepath .. " ] || wget -P /usr/local/nginx/tfsimg/ http://img.moscoper.test/v1/tfs/".. ngx.var.request_filepath);
os.execute(download_command);
--将tfs文件做剪裁
--local command="cd /usr/local/nginx/tfsimg ;/usr/local/GraphicsMagick/bin/gm convert " .. ngx.var.request_filepath .. " -resize " .. ngx.var.width .. "x" .. ngx.var.height .. " +profile \"*\" " .. ngx.var.request_filepath .. "_" .. ngx.var.width .. "x" .. ngx.var.height;
local command="cd /usr/local/nginx/tfsimg ;/usr/local/GraphicsMagick/bin/gm convert " .. ngx.var.request_filepath .. " -resize " .. ngx.var.width .. "x" .. ngx.var.height .. "  " .. ngx.var.request_filepath .. "_" .. ngx.var.width .. "x" .. ngx.var.height;
--ngx.say(command);
os.execute(command);
--将请求重定向到缓存文件夹
ngx.redirect("/reduce_img/" .. ngx.var.reduce_filename);
