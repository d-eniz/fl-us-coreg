function [fileList] = selectFiles()

[fileList, pathname] = uigetfile("*.h5", "Select files", "MultiSelect", "on");
app.UIFigure.Visible = 'off';
app.UIFigure.Visible = 'on';
if pathname == 0
    error("Choose files to proceed")
end
addpath(pathname)

if ischar(fileList)
    fileList = {fileList};
end

end