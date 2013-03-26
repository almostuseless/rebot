rebot
=====

gift    | .regex http://pastebin.com/raw.php?i=NX4Q2Gkv /(\d+\.\d+\.\d+\.\d+)/g
rebot   | [res: 0] [0:1-15: "111.111.111.111"] [1:18-32: "222.222.222.222"] [2:35-49: "333.333.333.333"] [3:52-66: "444.444.444.444"] [4:69-83: "555.555.555.555"]
gift    | .regex how now brown cow s/ow/ut/
rebot   | [res: 0] hut nut brutn cut
gift    | .regex ab cd ef gh /(\w{2})/g
rebot   | [res: 0] [0:1-2: "ab"] [1:4-5: "cd"] [2:7-8: "ef"] [3:10-11: "gh"]
