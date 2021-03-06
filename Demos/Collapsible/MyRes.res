        ��  ��                  f  4   H T M L   D E F A U L T         0           <html>
  <head>
    <title>Simple Tree View</title>
<style type="text/css"> 
  @import url(res:treeview.css) screen;
</style>
  </head>
  <body>
    <ul id="treeview" class="treeview">
      <li state="open"><img class="icon">Item1
        <ul>
          <li>Sub Item1</li>
          <li state="open"><img class="icon">Sub Item2
            <ul>
              <li>Sub Sub Item1</li>
              <li>Sub Sub Item2</li>
            </ul>
			</li>
          <li>Sub Item3</li>
          <li state="open"><img class="icon">Sub Item4
            <ul>
              <li>Sub Sub Item1</li>
              <li>Sub Sub Item2</li>
            </ul>
        </ul>
      </li>
      <li>Item2 caption</li>
      <li>Item3 caption</li>
      <li state="open"><img class="icon">Item4
        <ul>
          <li style="background-color:red yellow green blue; color:white; text-align:center; font-size:10pt"> 
            <p>Yep, collapsible items can have any content.</p>
            <p>Even input elements like input/text <INPUT type="text" value="hello" style="width:10em;" /><br>
            and input/hslider: <INPUT type="hslider" value="50" style="width:10em;" min="0" max="0" buddy="slider-buddy" />. Later one has this element <span id="slider-buddy" >x</span> as a "buddy".</p>
          </li>
        </ul>
      </li>
    </ul>
  </body>
</html>  �  4   C S S   T R E E V I E W         0           .treeview  { width: 50%; list-style-type: none; border: 1px solid darkkhaki; }
.treeview  li { padding: 1px 0px 1px 17px; }
.treeview  ul { margin-left:18px; }

/* inside treeview container, all li elements with existing 
'state' attribute will be collapsible  */
.treeview  li[state]{
    behavior:collapsible-by-icon;
    /* 
        Toggle 'state' to 'open' and 'close'.
        Sensitive area for collapsible items is first descendant 
        element having 'icon' class,
        see implementation: 
    */
    padding-left:0px;
}

/* all ul's inside open list item are visible */
.treeview li[state=open] > ul { 
    list-style-type: none; 
    /*background-color: white;*/
    color: black; 
    display:block;
    border-left: 1px dashed darkkhaki;
    border-bottom: 1px dashed darkkhaki;
    border-top: 1px dashed darkkhaki;
    margin-bottom: 4px;
}
/* all ul's inside closed list item are non-visible */
.treeview li[state=close] > ul { display:none; }

/* all images inside li with 'state' and with class 'icon' */
.treeview li[state] img.icon{
    width:13px;
    height:13px;
    margin:2px;
    vertical-align:middle;
    cursor:pointer;
}
/* icon image shows list-item-minus.png for open li*/
.treeview li[state=open] img.icon { background-image:url(data:text/css;base64,iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAIAAAD9iXMrAAAACXBIWXMAAAJQAAACUAHIS4ZAAAABa0lEQVR4nE2RPU7DQBCF989OghVaGqRINCgUSBTACRAtEiWnQOIGcBAaCg5ARUNDBXSAKCiIhJQqKCGJvbvemeWtLRD2yF5Z33sz8ywno6f3+8v510gqLaQUQsTIgjlyiJSqWF0bHp7Jh+vTjeGB7vZVvqJ0lqjgyJdUzcl+h3KK+hw/Gxmjyno6LxKadUVk8lVypcDBSpNLnQsOBr2kzlTW0Z1C9/rAEhQcvKVCGcwj8RIJlKIpKITCB9UO+v8yaNS08FxXod2itkw1xkRv2Ec8YzQ4UW1f765Gb7fwTCRu5qSPvD7YHwx2cTbJzC02d4639k6kNpBGquFNdpn2rVAzeIHzZBcRgdVWIMLfTdmV5Er2qAozGEwGkSKvsL9SLQcxe0t+SW6ZOEqcg7NCVAhCNhxmx1rBgQBHboG1TBSCyilnnRTVH8eh4Swny1JoIycfjy83F4vZGLmJNjVIBf5v85cjFf217aPzH5pjHqD3tVGRAAAAAElFTkSuQmCC) }
/* for closed li icon image shows list-item-plus.png */
.treeview li[state=close] img.icon { background-image:url(data:text/css;base64,iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAIAAAD9iXMrAAAACXBIWXMAAAJQAAACUAHIS4ZAAAABh0lEQVR4nC1Ru05bQRCd2Z3rmGDeEFnQQMGjCFAgUSFZ+YG0VKlSpsgPBD4AiZ6Cng+AAiEhJCoeihDQhgLxsgS2IcaO47s7y7lrdkerq7PnnnNmlp9uT//83qw/3hAbJg6ErYF80FSDC6HdPTjyeWmFT3Z+jC+WrO21totZQlDVpnOvzj07V3OumqaV8sWdgYS1BZE+kaEkGUmSwdvzI5GCtR+N6TLmgzE54rZhtsbkgYr0J8mwyMDV8TaQyEjgEMsIERNZIgEK9xBCBmSIiVedk8DTEPN63wzZ+k/Z6WJprOxfBPcIfrm3dX22T8wgNWoPu+vfgKNGZ+fGFqbxIVHp71Tp68yX5U6/Bxs/l77/cu4ltox+q0RevG8DUnXGNJE3mqRgeF+P1YAbMkCglaY1a1vMuXeeOkwODPh4/xqpqai2IK6aZ046vE/Tk/CCTCSBWkc2Uc9AMa04J4ZrcW7CuYrqvyiJh6kb6uHK/fHF4WqjWqas2/i+WNk4POJr8IWh4nxp7Q02OBmkn10a/AAAAABJRU5ErkJggg==) }

  body { 
  font-family:Verdana; font-size:10pt; 
  width:100%; height:100%;  
  background-color: window window threedface threedface;
  }

  #treeview 
  {
    overflow:auto; 
	height:400px; 
    width:600px;    
    
    margin:0;
    padding:1px;
  }  