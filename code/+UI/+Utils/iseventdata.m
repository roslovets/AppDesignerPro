function yes = iseventdata(var)
yes = startsWith(class(var), 'matlab.ui.eventdata');