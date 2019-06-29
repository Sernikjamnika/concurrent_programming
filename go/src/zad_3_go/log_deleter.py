import re
with open("result", mode='r') as file:
    lines = file.readlines()

with open("result", mode='w') as file:
    for line in lines:
        if not re.match(r"\[(WORKER|TASK DISPATCHER).*", line):
            file.write(line)