# Original Javascript made by Rasmus - http://www.peters1.dk
# Updated to Coffeescript

fire_no = 10 # Numbers of Rockets in one firework
fire_delay_in_seconds = 5 # Pause between the fireworks in seconds
fire_SameColor = false # true = The rockets have the same color in one firework

fire_j = 0

fire_browser_IE_NS = (document.body.clientHeight) ? 1 : 0
fire_browser_IE_SCM = (document.documentElement.clientHeight) ? 1 : 0
fire_browser_MOZ = (self.innerWidth) ? 1 : 0

if (fire_browser_IE_NS)
  fire_window_width = document.body.clientWidth
  fire_window_height = document.body.clientHeight
else if (fire_browser_IE_SCM)
  fire_window_width = document.documentElement.clientWidth
  fire_window_height = document.documentElement.clientHeight
else
  fire_window_width = self.innerWidth - 20
  fire_window_height = self.innerHeight

fire_top = 10
fire_bot = fire_window_height - 40
fire_mid = fire_window_width / 2

fire_posleft = new Array()
fire_postop = new Array()
fire_posvenafv = new Array()
fire_postopafv = new Array()
fire_time = new Array()
fire_topbang = new Array()
fire_icons = new Array()
fire_colors = new Array("orange","blue","yellow","red","green")
fire_pause = fire_delay_in_seconds*1000

for fire_i in [0..fire_no-1]
  fire_topbang[fire_i] = fire_top + Math.random()*200
  fire_postop[fire_i] = fire_bot
  fire_postopafv[fire_i] = 0
  fire_posleft[fire_i] = fire_mid
  if (fire_i % 2 == 0)
    fire_posvenafv[fire_i] = 4*Math.random()
  else
    fire_posvenafv[fire_i] = Math.random()*(-4)
  document.write("<div id='fire_no#{fire_i}' style='position: absolute; font-size: 15px; z-index: #{fire_i}; visibility: visible; top: #{fire_postop[fire_i]}px; left: #{fire_posleft[fire_i]}px;'></div>")


@fireOp = (fire_number) ->
  if fire_postop[fire_number] > (fire_top + fire_topbang[fire_number])
    fire_postop[fire_number] = fire_postop[fire_number] - fire_postopafv[fire_number]
    fire_posleft[fire_number] = fire_posleft[fire_number] + fire_posvenafv[fire_number]
    fire_postopafv[fire_number] = (fire_postop[fire_number]/40)
    document.getElementById("fire_no"+fire_number).style.top=fire_postop[fire_number]+"px"
    document.getElementById("fire_no"+fire_number).style.left=fire_posleft[fire_number]+"px"
    fire_time[fire_i] = setTimeout("fireOp("+fire_number+")",10)
  else
    clearTimeout("fire_time["+fire_number+"]")
    fireShowBang(fire_number)

@fireStart = () ->
  if fire_SameColor
    if fire_j == 4
      fire_j = 0
    else
      fire_j = fire_j + 1
  for fire_i in [0..fire_no-1]
    fire_j = Math.round(Math.random() * 4) unless fire_SameColor
    fire_icons[fire_i] = 'assets/'+fire_colors[fire_j]+'.gif'
    document.getElementById("fire_no"+fire_i).innerHTML = '<b>*</b>'
    document.getElementById("fire_no"+fire_i).style.color=fire_colors[fire_j]
    setTimeout("fireOp("+fire_i+")",(1500*Math.random()))

@fireShowBang = (fire_number) ->
  document.getElementById("fire_no"+fire_number).innerHTML = "<img src='#{fire_icons[fire_number]}' border='0' />"
  document.getElementById("fire_no"+fire_number).style.top = (fire_postop[fire_number] - 20)+"px"
  document.getElementById("fire_no"+fire_number).style.left = (fire_posleft[fire_number] - 40)+"px"
  setTimeout("fireReset("+fire_number+")",1000)

@fireReset = (fire_number) ->
  fire_topbang[fire_number] = fire_top + Math.random()*100
  fire_postop[fire_number] = fire_bot
  fire_postopafv[fire_number] = 4
  fire_posleft[fire_number] = fire_mid
  if fire_number % 2 == 0
    fire_posvenafv[fire_number] = 4*Math.random()
  else
    fire_posvenafv[fire_number] = Math.random()*(-4)

  document.getElementById("fire_no"+fire_number).innerHTML = ""
  document.getElementById("fire_no"+fire_number).style.top=fire_postop[fire_number]+"px"
  document.getElementById("fire_no"+fire_number).style.left=fire_posleft[fire_number]+"px"

  if (fire_number == fire_no-1)
    setTimeout("fireStart()",fire_pause)

jQuery ->
  $('[data-object~="fireworks-initialize"]').each( () ->
    fireStart()
  )
