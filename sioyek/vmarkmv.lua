local sioyek = arg[1]

-- move visual mark
if arg[2] == 'up' then
    os.execute(sioyek .. ' --execute-command "move_visual_mark_up"')
elseif arg[2] == 'down' then
    os.execute(sioyek .. ' --execute-command "move_visual_mark_down"')
end

-- center visual mark on screen
os.execute(sioyek .. [[ --execute-command "goto_mark" --execute-command-data '`']])
