module.exports = (robot) ->
  botname = process.env.HUBOT_SLACK_BOTNAME
  plusplus_re = /@([a-z0-9_\-\.]+)\+{2,}/ig
  minusminus_re = /@([a-z0-9_\-\.]+)\-{2,}/ig
  plusplus_minusminus_re = /@([a-z0-9_\-\.]+)[\+\-]{2,}/ig

  robot.hear plusplus_minusminus_re, (msg) ->
     sending_user = msg.message.user.name
     res = ''
     while (match = plusplus_re.exec(msg.message))
         user = match[1].replace(/\-+$/g, '')
         if user != sending_user
            count = (robot.brain.get(user) or 0) + 1
            robot.brain.set user, count
            res += "@#{user}++ [woot! now at #{count}]\n"
         else if process.env.KARMABOT_NO_GIF
            res += process.env.KARMABOT_NO_GIF
     while (match = minusminus_re.exec(msg.message))
         user = match[1].replace(/\-+$/g, '')
         count = (robot.brain.get(user) or 0) - 1
         robot.brain.set user, count
         res += "@#{user}-- [ouch! now at #{count}]\n"
     msg.send res.replace(/\s+$/g, '')

  robot.hear /// #{botname} \s+ @([a-z0-9_\-\.]+) ///i, (msg) ->
     user = msg.match[1].replace(/\-+$/g, '')
     count = robot.brain.get(user)
     if count != null
         point_label = if count == 1 then "point" else "points"
         msg.send "@#{user}: #{count} " + point_label
     else
         msg.send "@#{user} has no karma"
