import json, urllib.request, random, datetime, sys

URL="http://localhost:4000/graphql"
def q(query, token=None, variables=None):
    data=json.dumps({"query":query,"variables":variables or {}}).encode()
    req=urllib.request.Request(URL, data=data, headers={"content-type":"application/json"})
    if token: req.add_header("authorization","Bearer "+token)
    r=json.load(urllib.request.urlopen(req))
    if r.get("errors"): print("ERR:", r["errors"][:1], file=sys.stderr)
    return r.get("data")

tok=q('mutation{login(username:"admin",password:"admin"){token}}')["login"]["token"]

locs=[]
for name in ["Workshop","Machine Shop","Classroom B"]:
    d=q('mutation($l:String!){createLocation(location:$l){id location}}',tok,{"l":name})
    if d: locs.append(d["createLocation"]["id"])
print("locations:",len(locs))

names=[("Ada","Lovelace","mentor"),("Grace","Hopper","mentor"),("Alan","Turing","student"),
       ("Katherine","Johnson","student"),("Linus","Torvalds","student"),("Margaret","Hamilton","student"),
       ("Barbara","Liskov","student"),("Donald","Knuth","student"),("Radia","Perlman","mentor"),
       ("Jean","Bartik","student"),("Tim","Berners-Lee","student"),("Vint","Cerf","student")]
members=[]
for f,l,t in names:
    d=q('mutation($f:String!,$l:String!,$t:String!){createTeamMember(firstName:$f,lastName:$l,memberType:$t){id}}',
        tok,{"f":f,"l":l,"t":t})
    if d: members.append(d["createTeamMember"]["id"])
print("members:",len(members))

random.seed(7)
now=datetime.datetime.now(datetime.timezone.utc)
created=0; checkins=0
for day_off in range(0,75):
    day=now-datetime.timedelta(days=day_off)
    if day.weekday() in (6,):  # skip Sundays
        continue
    if random.random()<0.25:
        continue
    loc=random.choice(locs)
    start=day.replace(hour=random.choice([15,16,17]),minute=0,second=0,microsecond=0)
    end=start+datetime.timedelta(hours=random.choice([2,3,3,4]))
    d=q('''mutation($s:DateTime!,$e:DateTime!,$l:UUID!){createSession(startTime:$s,endTime:$e,locationId:$l){id}}''',
        tok,{"s":start.isoformat(),"e":end.isoformat(),"l":loc})
    if not d: continue
    sid=d["createSession"]["id"]; created+=1
    q('mutation($i:UUID!,$s:DateTime!,$e:DateTime!,$l:UUID!,$f:Boolean!){updateSession(id:$i,startTime:$s,endTime:$e,locationId:$l,finished:$f){id}}',
      tok,{"i":sid,"s":start.isoformat(),"e":end.isoformat(),"l":loc,"f":True})
    for m in random.sample(members, random.randint(4,11)):
        ci=start+datetime.timedelta(minutes=random.randint(-10,45))
        co=end+datetime.timedelta(minutes=random.choice([-30,-10,0,5,20,45,90]))
        if co<=ci: co=ci+datetime.timedelta(hours=1)
        r=q('''mutation($m:UUID!,$s:UUID!,$i:DateTime!,$o:DateTime){createTeamMemberSession(teamMemberId:$m,sessionId:$s,checkInTime:$i,checkOutTime:$o){id}}''',
            tok,{"m":m,"s":sid,"i":ci.isoformat(),"o":co.isoformat()})
        if r: checkins+=1
print("sessions:",created,"checkins:",checkins)
