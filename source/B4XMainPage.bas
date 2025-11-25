B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
'#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region
'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private splitMain As SplitPane
	Private splitRight As SplitPane
	Private CLV1 As CustomListView
	Private Tree As CLVTree
	Private lstHistory As ListView
	Private CustomListView1 As CustomListView
	Private LblView As B4XView
	Private TextArea1 As TextArea
	Private WebView1 As WebView
	Private PnlProperties As B4XView
	Private PD1 As PreferencesDialog
	Private Source As String
	Private PreviewSource As String
	Private SelectedIndex As Int
	Private HtmlParser As MiniHtmlParser
	'Dim Tidy As Tidy
	'Dim Sax As SaxParser
	Private CodeMirrorWrapper1 As CodeMirrorWrapper
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
	HtmlParser.Initialize
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	B4XPages.SetTitle(Me, "Simple HTML Editor")
	splitMain.LoadLayout("LeftSide")
	splitMain.LoadLayout("Center")
	splitMain.LoadLayout("RightSide")
	'limit the widths of the two side layouts
	splitMain.SetSizeLimits(0, 0, 200)
	splitMain.SetSizeLimits(2, 0, 300)
	CreateRightSizeLayout
	LoadViewList
	'GrowTree
	CustomListView1.DefaultTextBackgroundColor = xui.Color_White
	Tree.Initialize(CustomListView1)
	Tree.DefaultHeight = 36
	GrowTree2
	'lstViews.Items.AddAll(File.ReadList(File.DirAssets, "sites.txt"))
	'lstViews.SelectedIndex = 0
'	Dim inputstream As InputStream = File.OpenInput(File.DirAssets, "demo.html")
	
'	Tidy.Initialize
'	
'	Dim jo As JavaObject = Tidy
'	jo.GetFieldJO("tidy").RunMethod("setForceOutput", Array(True))
'	'Dim jo As JavaObject = Tidy
'	jo.GetFieldJO("tidy").RunMethod("setDocType", Array("omit"))
'	
'	Tidy.Parse(inputstream, File.DirApp, "temp.xml")
'	inputstream.Close
'	
'	Sax.Initialize
'	Sax.Parse(File.OpenInput(File.DirApp, "temp.xml"), "sax")

	CodeMirrorWrapper1.Language = "HTML"		'Set an initial style - All Suporrted Languages can be found as a list by calling in CMW_Utils.Languages
	CodeMirrorWrapper1.SetCode("")				'Set empty code or load some code
	CodeMirrorWrapper1.GetBase.Visible = False
	'CodeMirrorWrapper1.ReadOnly(True,True)
	'Dim L As List = CMW_Utils.Languages
	'For Each S As String In L
	'	Log(S)
	'Next
End Sub

'sub called once a page is loaded
Private Sub CodeMirrorWrapper1_Loaded
	Log("Loaded on Main")
'	CodeMirrorWrapper1.SetLanguageByFileType("test.b4i")
	
End Sub

'Sub required if the codechanged callback is reqistered.
Private Sub  CodeMirrorWrapper1_CodeChanged(Change As Object)
'	To get the full new Code
'	Dim Code As String = CodeMirrorWrapper1.GetCode

	Log("CodeChanged " & Change)
End Sub

'Private Sub Sax_StartElement (Uri As String, Name As String, Attributes As Attributes)
'	Log(Uri)
'	Log(Name)
'	Log(Attributes.GetValue2(Uri, Name))
'End Sub
'
'Private Sub Sax_EndElement (Uri As String, Name As String, Text As StringBuilder)
'	Log(Uri)
'	Log(Name)
'	Log(Text.ToString)
'End Sub

Private Sub CreateRightSizeLayout
	splitRight.LoadLayout("RightProperties")
	splitRight.LoadLayout("RightMessageLog")
	'lstProperties.Items.Add("http://www.b4x.com")
End Sub

'Private Sub SplitRight_Resize (Width As Double, Height As Double)
'	PD1.mBase.Height = Height - 60dip
'End Sub

'Private Sub PnlProperties_Resize (Width As Double, Height As Double)
'	If PD1.IsInitialized Then 
'		PD1.Dialog.Resize(Width, Height)
'		PD1.Dialog.mParent.Top = 0
'	End If
'End Sub

Private Sub btnDesigner_Click
	CustomListView1.AsView.Visible = True
	TextArea1.Visible = False
	WebView1.Visible = False
	CodeMirrorWrapper1.GetBase.Visible = False
	
	GrowTree2
End Sub

Private Sub btnCode_Click
	CustomListView1.AsView.Visible = False
	TextArea1.Visible = True
	WebView1.Visible = False
	CodeMirrorWrapper1.GetBase.Visible = True
	CodeMirrorWrapper1.SetCode(Source)
	
	'GrowTree2
	'TestOutput
	'TextArea1.Text = Source' TreeToJson
End Sub

Private Sub btnPreview_Click
	CustomListView1.AsView.Visible = False
	TextArea1.Visible = False
	WebView1.Visible = True
	CodeMirrorWrapper1.GetBase.Visible = False
	
	'GrowTree2
	
	File.WriteString(File.DirApp, "index.html", Source)
	WebView1.LoadHtml(File.ReadString(File.DirApp, "index.html"))
	PreviewSource = Source
	Dim assets As String = File.Combine(File.DirApp, "www")
	Dim style1 As String = "styles/bootstrap.min.css"
	PreviewSource = PreviewSource.Replace(style1, File.GetUri(assets, style1))
	Dim script1 As String = "js/jquery-3.7.1.min.js"
	PreviewSource = PreviewSource.Replace(script1, File.GetUri(assets, script1))
	Dim script2 As String = "js/bootstrap.bundle.min.js"
	PreviewSource = PreviewSource.Replace(script2, File.GetUri(assets, script2))
	Dim logo1 As String = "img/logo.png"
	PreviewSource = PreviewSource.Replace(logo1, File.GetUri(assets, logo1))
	'File.WriteString(File.DirApp, "index.html", PreviewSource)
	WebView1.LoadHtml(PreviewSource)
End Sub

Private Sub LoadViewList
	CLV1.Add(CreateListItem("p", xui.Color_ARGB(255, 255, 255, 245)), "p")
	CLV1.Add(CreateListItem("h1", xui.Color_ARGB(255, 255, 255, 245)), "h1")
	CLV1.Add(CreateListItem("div", xui.Color_ARGB(255, 255, 255, 245)), "div")
	CLV1.Add(CreateListItem("span", xui.Color_ARGB(255, 255, 255, 245)), "span")
	CLV1.Add(CreateListItem("form", xui.Color_ARGB(255, 255, 255, 245)), "form")
	CLV1.Add(CreateListItem("label", xui.Color_ARGB(255, 255, 255, 245)), "label")
	CLV1.Add(CreateListItem("button", xui.Color_ARGB(255, 255, 255, 245)), "button")
	CLV1.Add(CreateListItem("input", xui.Color_ARGB(255, 255, 255, 245)), "input")
	'CLV1.Add(CreateListItem("input (text)"), "input-text")
	'CLV1.Add(CreateListItem("input (email)"), "input-email")
	'CLV1.Add(CreateListItem("input (password)"), "input-password")
	'CLV1.Add(CreateListItem("input (date)"), "input-date")
	CLV1.Add(CreateListItem("select", xui.Color_ARGB(255, 255, 255, 245)), "select")
	CLV1.Add(CreateListItem("table", xui.Color_ARGB(255, 255, 255, 245)), "table")
	CLV1.Add(CreateListItem("tbody", xui.Color_ARGB(255, 255, 255, 245)), "tbody")
	CLV1.Add(CreateListItem("th", xui.Color_ARGB(255, 255, 255, 245)), "th")
	CLV1.Add(CreateListItem("tr", xui.Color_ARGB(255, 255, 255, 245)), "tr")
	CLV1.Add(CreateListItem("td", xui.Color_ARGB(255, 255, 255, 245)), "td")
	CLV1.Add(CreateListItem("hr", xui.Color_ARGB(255, 255, 255, 245)), "hr")
End Sub

Private Sub CreateListItem (Text As String, Color As Int) As B4XView
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, 200dip, 50dip)
	pnl.LoadLayout("ListItemView")
	pnl.Color = Color
	LblView.Text = Text
	Return pnl
End Sub

Private Sub GrowTree2
'	CustomListView1.DefaultTextBackgroundColor = xui.Color_White
'	Tree.Initialize(CustomListView1)
'	Tree.DefaultHeight = 36

	Dim html1 As Tag = Html.lang("en")
	'html1.comment(" velocity.vm ")
	Dim head1 As Tag
	head1.Initialize("head")
	head1.up(html1)
	head1.meta_preset
	'head1.Text("$csrf")
	head1.title("Demo Website")
	head1.linkCss("styles/bootstrap.min.css")
	'head1.linkCss("https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css")
	Dim body1 As Tag = Body.up(html1)
	Dim div1 As Tag = Div.cls("container mt-5").up(body1)
	Dim form1 As Tag = Form.up(div1)
	Dim div2 As Tag = Div.cls("mb-3").up(form1)
	Dim lbl1 As Tag = Label.forId("exampleInput").cls("form-label").Text("Enter something").up(div2)
	Dim input1 As Tag = Input.typeOf("text").cls("form-control").id("exampleInput").attr("placeholder", "Type here...").up(div2)
	Dim button1 As Tag = Button.typeOf("button").cls("btn btn-primary mt-3").id("showToast").Text("Submit").up(form1)
	body1.newline
	body1.comment(" Toast Notification ")
	
	Dim toast As String = $"<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
        <div id="liveToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true" data-bs-autohide="false">
            <div class="toast-header">
				<img src="img/logo.png" class="rounded me-2" width="24" height="24" alt="B4X">
                <strong class="me-auto">Notification</strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body">
                Form submitted successfully!
            </div>
        </div>
    </div>"$
'	Dim node1 As HtmlNode = HtmlParser.Parse(toast)
'	If node1.IsInitialized Then
'		For Each att As HtmlAttribute In node1.Children.Get(0).As(HtmlNode).Attributes
'			Log($"${att.Key}: ${att.Value.Trim}"$)
'		Next
		Dim toast1 As Tag = Html.Parse(toast) ' ConvertTagNodeToTag(node1)
		'Log(toast1.build)
		toast1.up(body1)
'	End If

	body1.newline
	Dim script1 As Tag = Html.create("script").srcOf("js/jquery-3.7.1.min.js").up(body1)
	Dim script2 As Tag = Html.create("script").srcOf("js/bootstrap.bundle.min.js").up(body1)
	Dim script3 As Tag = Html.create("script").multiline.Text($"
		$(document).ready(function() {
	    	var toastElement = $("#liveToast")
	    	var toast = new bootstrap.Toast(toastElement[0])

		    $("#showToast").click(function() {
				$(".toast-body").html("Submited value: " + $("#exampleInput").val())
		        toast.show()
		    })
		})"$).up(body1)
	
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	'doc.Append(TAB)
	doc.Append(html1.build)
	Source = doc.ToString
	
	Tree.Clear
	Dim ihtml As CLVTreeItem = AddTreeItem(Tree.Root, html1.TagName, Null, html1)
	Dim ihead As CLVTreeItem = AddTreeItem(ihtml, head1.TagName, Null, head1)
	For Each t1 As Tag In head1.Children
		'Log(t1.TagName)
		AddTreeItem(ihead, t1.TagName, Null, t1)
	Next
	Dim ibody As CLVTreeItem = AddTreeItem(ihtml, body1.TagName, Null, body1)
	Dim idiv1 As CLVTreeItem = AddTreeItem(ibody, div1.TagName & $" [${div1.ClassesAsString}]"$, Null, div1)
	
	'Dim idiv2 As CLVTreeItem = AddTreeItem(idiv1, div2.TagName, Null, div2)
	'Dim idiv3 As CLVTreeItem = AddTreeItem(idiv2, div2.TagName, Null, div2)
	'AddTreeItem(idiv3, div2.TagName, Null, div2)
	
	'Dim idiv2 As CLVTreeItem = AddTreeItem(idiv1, div2.TagName, Null, div2)
	'Dim idiv3 As CLVTreeItem = AddTreeItem(idiv2, div2.TagName, Null, div2)
	'AddTreeItem(idiv3, div2.TagName, Null, div2)
	
	'Dim idiv2 As CLVTreeItem = AddTreeItem(idiv1, div2.TagName, Null, div2)
	'Dim idiv3 As CLVTreeItem = AddTreeItem(idiv2, div2.TagName, Null, div2)
	'AddTreeItem(idiv3, div2.TagName, Null, div2)
	
	Dim iform1 As CLVTreeItem = AddTreeItem(idiv1, form1.TagName, Null, form1)
	Dim idiv2 As CLVTreeItem = AddTreeItem(iform1, div2.TagName & $" [${div2.ClassesAsString}]"$, Null, div2)
	AddTreeItem(idiv2, lbl1.TagName & $" [${lbl1.ClassesAsString}]"$, Null, lbl1)
	AddTreeItem(idiv2, input1.TagName & $" [${input1.ClassesAsString}]"$, Null, input1)
	AddTreeItem(idiv2, button1.TagName & $" [${button1.ClassesAsString}]"$, Null, button1)
	
	Dim itoast1 As CLVTreeItem = AddTreeItem(ibody, toast1.TagName & $" [${toast1.ClassesAsString}]"$, Null, toast1)
	Dim iflex1 As Tag = toast1.Child(0)
	Dim idiv2 As CLVTreeItem = AddTreeItem(itoast1, iflex1.TagName & $" [${iflex1.ClassesAsString}]"$, Null, iflex1)
	For Each t1 As Tag In iflex1.Children
		'Log(t1.TagName & " : " & t1.Parent)
		AddTreeItem(idiv2, t1.TagName & $" [${t1.ClassesAsString}]"$, Null, t1)
	Next
	
	AddTreeItem(ibody, script1.TagName, Null, script1)
	AddTreeItem(ibody, script2.TagName, Null, script2)
	AddTreeItem(ibody, script3.TagName, Null, script3)
	'Tree.Refresh
End Sub

Private Sub AddTreeItem (Parent As CLVTreeItem, Text As Object, Image As B4XBitmap, Tag1 As Object) As CLVTreeItem
	Return Tree.AddItem(Parent, Text, Image, Tag1)
End Sub

Public Sub GetLabelColor (Tag1 As Object) As Int
	Dim name As String = Tag1
	Select name
		Case "head"
			Return 0xFF2E8B57
		Case "body"
			Return 0xFF8A2BE2
		Case "div"
			Return 0xFFDC143C
		Case "label"
			Return 0xFF6A5ACD
		Case "form"
			Return 0xFF1E90FF
		Case "input"
			Return 0xFF00CED1
		Case "button"
			Return 0xFFFF1493
		Case "script"
			Return 0xFFFFD700
		Case Else
			Return xui.Color_DarkGray
	End Select
End Sub

'Sub ConvertTagNodeToTag (node1 As HtmlNode) As Tag
'	Dim parent As Tag
'	If node1.Name = "root" Then
'		For Each child As HtmlNode In node1.Children
'			If child.Name = "text" Then Continue
'			node1 = child
'			parent.Initialize(node1.Name)
'		Next
'	Else
'		parent.Initialize(node1.Name)
'	End If
'
'	If node1.Name = "text" Then
'		Dim value As String = HtmlParser.GetAttributeValue(node1, "value", "").Trim
'		If value.Length > 0 Then
'			parent.Text(value)
'			Return parent
'		End If
'	End If
'	For Each att As HtmlAttribute In node1.Attributes
'		parent.attr(att.Key, att.Value)
'	Next
'	For Each child As HtmlNode In node1.Children
'		If child.Name = "text" Then
'			Dim value As String = HtmlParser.GetAttributeValue(child, "value", "").Trim
'			'Log($"[${value}]"$)
'			If value.Length > 0 Then
'				parent.Text(value)
'			End If
'			Continue
'		End If
'		Dim tag2 As Tag = ConvertTagNodeToTag(child)
'		parent.add(tag2)
'	Next
'	'Log(parent.build)
'	Return parent
'End Sub

'Sub TestOutput
'	Source = "<!doctype html>"
'	Dim MyList As List = TreeToList
'	For Each Item In MyList
'		Log(Item)
'	Next
'End Sub

Public Sub TreeToList As List
	Dim l As List
	l.Initialize
	TreeToItems(Tree.Root, l)
	Return l
End Sub

Private Sub TreeToItems (ParentTreeNode As CLVTreeItem, ParentList As List)
	For Each child As CLVTreeItem In ParentTreeNode.Children
		Dim m As Map = CreateMap() 'CreateMap("text": child.Text, "tag": child.Tag)
		'Dim h As HtmlElement = child.Tag
		Dim h As Tag = child.Tag
		
		'Dim OpenTag As String = h.HtmlTag.As(String)
		Dim OpenTag As String = $"<${h.TagName}>"$
		Dim CloseTag As String = OpenTag.Replace("<", "</")
		'If h.Attributes.IsInitialized Then ' And h.Attributes.Size > 0 Then
		'	Dim Attributes As String
		'	For Each ha As HtmlAttribute In h.Attributes
		'		Dim newValue As String = ha.Value.As(String).Replace("{", "").Replace("}", "")
		'		Attributes = Attributes &  $" ${ha.TagName}="${newValue}""$
		'	Next
		'	OpenTag = OpenTag.Replace(">", Attributes & ">")
		'End If
		If h.Attributes.IsInitialized Then
			Dim Attributes As String
			For Each key As String In h.Attributes.Keys
				Dim newValue As String = h.Attributes.Get(key).As(String).Replace("{", "").Replace("}", "")
				If key = "class" Then 
					newValue = newValue.Replace("[", "").Replace("]", "")
				End If
				Attributes = Attributes &  $" ${key}="${newValue}""$
			Next
			OpenTag = OpenTag.Replace(">", Attributes & ">")
		End If
		OpenTag = OpenTag.Replace("<>", "")
		'Source = Source & CRLF & OpenTag
		
		'If h.innerText.Length > 0 Then Source = Source & h.innerText
		
		ParentList.Add(m)
		If child.Children.IsInitialized And child.Children.Size > 0 Then
			Dim children As List
			children.Initialize
			m.Put("children", children)
			TreeToItems(child, children)
		End If
		Select CloseTag
			Case "</meta>", "</hr>", "</input>", "</img>", "</link>"
				' self closing tag
			Case Else
				CloseTag = CloseTag.Replace("</>", "")
				'Source = Source & CloseTag
		End Select
	Next
End Sub

'Private Sub CLV1_ItemClick (Index As Int, Value As Object)
'	Select Value
'		Case "p"
'			Dim bc As HtmlElement = CreateHtmlElement("<p>", Null, "&nbsp;")
'			Tree.AddItem(body, bc.HtmlTag, Null, bc)
'		Case "h1"
'			Dim bc As HtmlElement = CreateHtmlElement("<h1>", Null, "&nbsp;")
'			Tree.AddItem(body, bc.HtmlTag, Null, bc)
'		Case "div"
'			Dim bc As HtmlElement = CreateHtmlElement("<div>", Array(CreateHtmlAttribute("class", "col-md-6")), "")
'			Tree.AddItem(body, bc.HtmlTag, Null, bc)
'		Case "span"
'			Dim bc As HtmlElement = CreateHtmlElement("<span>", Array(CreateHtmlAttribute("class", "text-decoration-underline")), "")
'			Tree.AddItem(body, bc.HtmlTag, Null, bc)
'		Case "form"
'			Dim dc As HtmlElement = CreateHtmlElement("<form>", Array(CreateHtmlAttribute("id", "form1"), CreateHtmlAttribute("class", "form")), "")
'			form2 = Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'		Case "label"
'			Dim dc As HtmlElement = CreateHtmlElement("<label>", Array(CreateHtmlAttribute("for", "username"), CreateHtmlAttribute("class", "form-label")), "username")
'			Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'		Case "button"
'			Dim dc As HtmlElement = CreateHtmlElement("<button>", Array(CreateHtmlAttribute("type", "button"), CreateHtmlAttribute("id", "button1"), CreateHtmlAttribute("class", "btn btn-primary")), "Button1")
'			Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'		Case "input"
'			Dim dc As HtmlElement = CreateHtmlElement("<input>", Array(CreateHtmlAttribute("type", "text"), CreateHtmlAttribute("id", "username"), CreateHtmlAttribute("class", "form-control")), "")
'			Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'		Case "select"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'		Case "table"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'		Case "tbody"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'		Case "th"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'		Case "tr"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'		Case "td"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'		Case "hr"
'			xui.MsgboxAsync("View not yet implemented", "Demo")
'	End Select
'End Sub

'Private Sub lstViews_MouseClicked (EventData As MouseEvent)
'	Select EventData.ClickCount
'		Case 2
'			Select lstViews.SelectedItem
'				Case "<div>"
'					Dim bc As HtmlElement = CreateHtmlElement("<div>", Array(CreateHtmlAttribute("class", "col-md-6")), "")
'					Tree.AddItem(body, bc.HtmlTag, Null, bc)
'				Case "<p>"
'					Dim bc As HtmlElement = CreateHtmlElement("<p>", Null, "&nbsp;")
'					Tree.AddItem(body, bc.HtmlTag, Null, bc)
'				Case "<h1>"
'					Dim bc As HtmlElement = CreateHtmlElement("<h1>", Null, "&nbsp;")
'					Tree.AddItem(body, bc.HtmlTag, Null, bc)
'				Case "<span>"
'					Dim bc As HtmlElement = CreateHtmlElement("<span>", Array(CreateHtmlAttribute("class", "text-decoration-underline")), "")
'					Tree.AddItem(body, bc.HtmlTag, Null, bc)
'				Case "<form>"
'					Dim dc As HtmlElement = CreateHtmlElement("<form>", Array(CreateHtmlAttribute("id", "form1"), CreateHtmlAttribute("class", "form")), "")
'					form2 = Tree.AddItem(div2, dc.HtmlTag, Null, dc)				
'				Case $"<label>"$
'					Dim dc As HtmlElement = CreateHtmlElement("<label>", Array(CreateHtmlAttribute("for", "username"), CreateHtmlAttribute("class", "form-label")), "username")
'					Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'				Case $"<input type="text">"$
'					Dim dc As HtmlElement = CreateHtmlElement("<input>", Array(CreateHtmlAttribute("type", "text"), CreateHtmlAttribute("id", "username"), CreateHtmlAttribute("class", "form-control")), "")
'					Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'				Case $"<input type="email">"$
'					Dim dc As HtmlElement = CreateHtmlElement("<input>", Array(CreateHtmlAttribute("type", "email"), CreateHtmlAttribute("id", "email"), CreateHtmlAttribute("class", "form-control")), "")
'					Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'				Case $"<input type="password">"$
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case $"<input type="date">"$
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case $"<button>"$
'					Dim dc As HtmlElement = CreateHtmlElement("<button>", Array(CreateHtmlAttribute("type", "button"), CreateHtmlAttribute("id", "button1"), CreateHtmlAttribute("class", "btn btn-primary")), "Button1")
'					Tree.AddItem(div2, dc.HtmlTag, Null, dc)
'				Case "<select>"
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case "<table>"
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case "<th>"
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case "<tbody>"
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case "<tr>"
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case "<td>"
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'				Case Else
'					xui.MsgboxAsync("View not yet implemented", "Demo")
'			End Select
'	End Select
'End Sub

Private Sub CustomListView1_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Tree.CLV_VisibleRangeChanged(FirstIndex, LastIndex)
End Sub

Private Sub CustomListView1_ItemClick (Index As Int, Value As Object)
	Dim item As CLVTreeItem = Value
	'Log(item.Text)
	'Log(item.Tag)
	Dim Data As Map' = CreateMap()
	Data.Initialize
	'Dim element As HtmlElement = item.Tag
	Dim element As Tag = item.Tag
	PD1.Initialize(PnlProperties, element.TagName, PnlProperties.Width, PnlProperties.Height)

	If element.Attributes.IsInitialized Then
		If element.innerText.Length > 0 Then
			PD1.AddSeparator("Main")
			'Log( element.innerText )
			PD1.AddTextItem("Text", "Text")
			Data.Put("Text", element.innerText)
			'Log(Data.Size)
		End If
		PD1.AddSeparator("Attributes")
		'Dim AttributeList As List = element.Attributes
		'Log(AttributeList)
		'Dim Data As Map = CreateMap()
		'For Each AttributeItem As HtmlAttribute In AttributeList
		'	'Log(AttributeItem)
		'	PD1.AddTextItem(AttributeItem.TagName, AttributeItem.TagName)
		'	Data.Put(AttributeItem.TagName, AttributeItem.Value)
		'Next
		Dim Attributes As Map = element.Attributes
		For Each Key As String In Attributes.keys
			'Log(AttributeItem)
			PD1.AddTextItem(Key, Key)
			Data.Put(Key, Attributes.Get(Key))
		Next
	Else
		If element.innerText.Length > 0 Then
			PD1.AddSeparator("Main")
			'Log( element.innerText )
			PD1.AddTextItem("Text", "Text")
			Data.Put("Text", element.innerText)
			'Log(Data.Size)
		End If
	End If

	'PD1.AddBooleanItem("Key1", "True/False")
	'Log(Data.Size)
	Wait For (PD1.ShowDialog(Data, "OK", "CANCEL")) Complete (Result As Int)
	'If Result = xui.DialogResponse_Positive Then
	'	Log("ok")
	'End If
	CustomListView1.GetPanel(SelectedIndex).GetView(0).Color = xui.Color_White
	CustomListView1.GetPanel(Index).GetView(0).Color = xui.Color_Cyan
	SelectedIndex = Index
End Sub

Sub WebView1_PageFinished (Url As String)
	'txtUrl.Text = Url
End Sub

Sub lstHistory_SelectedIndexChanged(Index As Int)
	If Index = -1 Then Return
	'txtUrl.Text = lstHistory.Items.Get(Index)
	'lstHistory.SelectedIndex = -1
	'btnGo_Action
End Sub

Private Sub btnCollapseAll_Click
	Tree.CollapseAll
End Sub

Private Sub btnExpandAll_Click
	Tree.ExpandAll
End Sub

Sub WebViewAssetFile (FileName As String) As String 'ignore
   #if B4J
	Return File.GetUri(File.DirAssets, FileName)
   #Else If B4A
     Dim jo As JavaObject
     jo.InitializeStatic("anywheresoftware.b4a.objects.streams.File")
     If jo.GetField("virtualAssetsFolder") = Null Then
       Return "file:///android_asset/" & FileName.ToLowerCase
     Else
       Return "file://" & File.Combine(jo.GetField("virtualAssetsFolder"), _
       jo.RunMethod("getUnpackedVirtualAssetFile", Array As Object(FileName)))
     End If
   #Else If B4i
     Return $"file://${File.Combine(File.DirAssets, FileName)}"$
   #End If
End Sub

'Public Sub CreateHtmlAttribute (Name As String, Value As Object) As HtmlAttribute
'	Dim t1 As HtmlAttribute
'	t1.Initialize
'	t1.TagName = Name
'	t1.Value = Value
'	Return t1
'End Sub
'
'Public Sub CreateHtmlElement (HtmlTag As Object, Attributes As List, Content As String) As HtmlElement
'	Dim t1 As HtmlElement
'	t1.Initialize
'	t1.HtmlTag = HtmlTag
'	t1.Attributes = Attributes
'	t1.Content = Content
'	Return t1
'End Sub