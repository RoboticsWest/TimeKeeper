import random, datetime, subprocess
random.seed(11)

def psql(sql):
    return subprocess.run(["podman","exec","-i","tk-migtest","psql","-U","postgres","-d","timekeeper","-t","-A","-c",sql],
                          capture_output=True, text=True).stdout.strip()

members=[l for l in psql("select id from team_members;").split("\n") if l]
sessions=[l.split("|") for l in psql("select id, start_time, end_time from sessions;").split("\n") if l]
print("members",len(members),"sessions",len(sessions))

rows=[]
for sid, st, et in sessions:
    start=datetime.datetime.fromisoformat(st.strip())
    end=datetime.datetime.fromisoformat(et.strip())
    for m in random.sample(members, random.randint(4, min(11,len(members)))):
        ci=start+datetime.timedelta(minutes=random.randint(-10,45))
        co=end+datetime.timedelta(minutes=random.choice([-40,-15,0,5,25,50,95,140]))
        if co<=ci: co=ci+datetime.timedelta(hours=1)
        rows.append(f"(gen_random_uuid(),'{m}','{sid}','{ci.isoformat()}','{co.isoformat()}')")

CH=500
for i in range(0,len(rows),CH):
    sql="insert into team_member_sessions (id, team_member_id, session_id, check_in_time, check_out_time) values "+",".join(rows[i:i+CH])+";"
    psql(sql)
print("inserted", len(rows))
print("count:", psql("select count(*) from team_member_sessions;"))
