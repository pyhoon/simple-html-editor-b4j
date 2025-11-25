B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.08
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private UICache As List
	Public Root As CLVTreeItem
	Private arrowbmp As B4XBitmap
	Private mCLV As CustomListView
	Private DragTop, DragY As Int
	Public DefaultHeight As Int = 50dip
	Private Const IndentPerLevel As Int = 20dip
	Private Const LABEL_INDEX = 2, ARROW_INDEX = 0, IMAGE_INDEX = 1, DRAGGER_INDEX = 3, TRASH_INDEX = 4, PANELTOUCH_INDEX = 5 As Int 'ignore
	Type CLVTreeItem (Text As Object, Image As B4XBitmap, Tag As Object, Children As List, _
		Parent As CLVTreeItem, InternalExpanded As Boolean, InternalPanel As B4XView)
End Sub

Public Sub Initialize (CLV As CustomListView)
	mCLV = CLV
	Root.Initialize
	Root.Children.Initialize
	Root.InternalExpanded = True
	UICache.Initialize
	'arrowbmp = xui.LoadBitmapResize(File.DirAssets, "arrow.png", 20dip, 20dip, True)
	arrowbmp = xui.LoadBitmapResize(File.DirAssets, "plus.png", 32dip, 32dip, True)
	mCLV.AnimationDuration = 0
End Sub

'Public Sub getCLV As CustomListView
'	Return mCLV
'End Sub

'Adds an item to the tree.
'Parent - item will be added to this parent.
'Text - A String or CSBuilder.
'Image - Optional image.
'Tag - Placeholder that can hold any other information needed.
Public Sub AddItem (Parent As CLVTreeItem, Text As Object, Image As B4XBitmap, Tag1 As Object) As CLVTreeItem
	Dim Item As CLVTreeItem = CreateCLVTreeItem(Text, Image, Tag1, Parent)
	Dim height As Int = DefaultHeight
	Parent.Children.Add(Item)
	Item.InternalPanel = xui.CreatePanel("")
	Item.InternalPanel.Color = mCLV.DefaultTextBackgroundColor
	Item.InternalPanel.SetLayoutAnimated(0, 0, 0, mCLV.AsView.Width, height)
	If Parent.InternalExpanded And ItemWasAddedToCLV(Parent) Then
		AddItemToCLV(Item, -1)
		If Parent.Children.Size = 1 Then UpdateExpandIcon(Parent)
	End If
	Return Item
End Sub

Private Sub ItemWasAddedToCLV (Item As CLVTreeItem) As Boolean
	Return IIf(Item = Root, True, Item.InternalPanel.IsInitialized And Item.InternalPanel.Parent.IsInitialized)
End Sub

Private Sub ItemHasUI (Item As CLVTreeItem) As Boolean
	Return Item.InternalPanel.IsInitialized And Item.InternalPanel.NumberOfViews > 0
End Sub

'index = -1 to add as last element.
Private Sub AddItemToCLV (Item As CLVTreeItem, Index As Int)
	Dim ParentIndex As Int = IIf(Item.Parent = Root, -1, mCLV.GetItemFromView(Item.Parent.InternalPanel))
	mCLV.InsertAt(ParentIndex + 1 + CountVisibleChildren(Item.Parent, Index) - IIf(Index = -1, 1, 0), Item.InternalPanel, Item)
	If Item.InternalExpanded Then
		Dim Index As Int
		For Each child As CLVTreeItem In Item.Children
			AddItemToCLV(child, Index)
			Index = Index + 1
		Next
	End If
End Sub

'Removes an item from the tree.
Public Sub RemoveItem (Item As CLVTreeItem)
	RemoveItemFromCLV(Item)
	Item.Parent.Children.RemoveAt(Item.Parent.Children.IndexOf(Item))
	If Item.Parent.Children.Size = 0 Then UpdateExpandIcon(Item.Parent)
End Sub

Private Sub RemoveItemFromCLV (Item As CLVTreeItem)
	If ItemWasAddedToCLV(Item) = False Then Return
	Dim index As Int = mCLV.GetItemFromView(Item.InternalPanel)
	mCLV.RemoveAt(index)
	Item.InternalPanel.Color = Item.InternalPanel.Parent.Color
	Item.InternalPanel.RemoveViewFromParent
	For Each child As CLVTreeItem In Item.Children
		RemoveItemFromCLV(child)
	Next
End Sub

Private Sub CountVisibleChildren (Parent As CLVTreeItem, UpUntilIndex As Int) As Int
	Dim count As Int = IIf(UpUntilIndex = -1, Parent.Children.Size, UpUntilIndex)
	For i = 0 To count - 1
		Dim Item As CLVTreeItem = Parent.Children.Get(i)
		If Item.InternalExpanded Then count = count + CountVisibleChildren(Item, -1)
	Next
	Return count
End Sub

Private Sub CreateCLVTreeItem (Text As Object, Image As B4XBitmap, Tag1 As Object, Parent As CLVTreeItem) As CLVTreeItem
	Dim t1 As CLVTreeItem
	t1.Initialize
	t1.Text = Text
	t1.Image = Image
	t1.Tag = Tag1
	t1.Children.Initialize
	t1.Parent = Parent
	t1.InternalExpanded = True
	Return t1
End Sub

Public Sub CLV_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	For i = 0 To mCLV.Size - 1
		Dim Item As CLVTreeItem = mCLV.GetValue(i)
		If i >= FirstIndex - 3 And i <= LastIndex + 3 Then
			If ItemHasUI(Item) = False Then
				CreateItemUI(Item)
			End If
		Else if ItemHasUI(Item) Then
			UICache.Add(Item.InternalPanel.GetView(0))
			Item.InternalPanel.GetView(0).RemoveViewFromParent
		End If
	Next
End Sub

'Removes all items.
Public Sub Clear
	For i = 0 To mCLV.Size - 1
		Dim Item As CLVTreeItem = mCLV.GetValue(i)
		If ItemHasUI(Item) Then
			UICache.Add(Item.InternalPanel.GetView(0))
			Item.InternalPanel.GetView(0).RemoveViewFromParent
		End If
	Next
	mCLV.Clear
	Root.Children.Clear
End Sub

'Expands all items.
Public Sub ExpandAll
	ExpandOrCollapseAllImpl(Root, True)
	mCLV.Refresh
End Sub

'Collapses all items.
Public Sub CollapseAll
	For i = 0 To mCLV.Size - 1
		Dim raw As CLVItem = mCLV.GetRawListItem(i)
		raw.Panel.GetView(0).Color = raw.Panel.Color
		raw.Panel.GetView(0).RemoveViewFromParent
	Next
	mCLV.Clear
	ExpandOrCollapseAllImpl(Root, False)
	Dim index As Int
	For Each item As CLVTreeItem In Root.Children
		AddItemToCLV(item, index)
		UpdateExpandIcon(item)
		index = index + 1
	Next
	mCLV.Refresh
End Sub

Private Sub ExpandOrCollapseAllImpl (Parent As CLVTreeItem, Expand As Boolean)
	If Expand Then
		ExpandImpl(Parent)
	Else if Parent <> Root Then
		Parent.InternalExpanded = False
	End If
	For Each child As CLVTreeItem In Parent.Children
		ExpandOrCollapseAllImpl(child, Expand)
	Next
End Sub

'Expands an item.
Public Sub ExpandItem (Item As CLVTreeItem)
	ExpandImpl(Item)
	mCLV.Refresh
End Sub

'Collapses an item.
Public Sub CollapseItem (Item As CLVTreeItem)
	If Item = Root Or Item.InternalExpanded = False Then Return
	CollapseImpl(Item)
	mCLV.Refresh
End Sub

Private Sub ExpandImpl (Item As CLVTreeItem)
	If Item = Root Or Item.InternalExpanded = True Then Return
	Item.InternalExpanded = True
	UpdateExpandIcon(Item)
	For i = 0 To Item.Children.Size - 1
		AddItemToCLV(Item.Children.Get(i), i)
	Next
End Sub

Private Sub CollapseImpl (Item As CLVTreeItem)
	Item.InternalExpanded = False
	UpdateExpandIcon(Item)
	For Each child As CLVTreeItem In Item.Children
		RemoveItemFromCLV(child)
	Next
End Sub

'Private Sub UpdateExpandIcon (Item As CLVTreeItem)
'	If ItemHasUI(Item) = False Then Return
'	Dim expandicon As B4XImageView = Item.InternalPanel.GetView(0).GetView(0).Tag
'	expandicon.mBase.Visible = Item.Children.Size > 0
'	expandicon.mBase.Rotation = IIf(Item.InternalExpanded, 0, 270)
'End Sub
Private Sub UpdateExpandIcon (Item As CLVTreeItem)
	If ItemHasUI(Item) = False Then Return
	Dim expandicon As B4XImageView = Item.InternalPanel.GetView(0).GetView(0).Tag
	expandicon.mBase.Visible = Item.Children.Size > 0
	If Item.InternalExpanded Then
		expandicon.Bitmap = xui.LoadBitmapResize(File.DirAssets, "minus.png", 32dip, 32dip, True)
	Else
		expandicon.Bitmap = xui.LoadBitmapResize(File.DirAssets, "plus.png", 32dip, 32dip, True)
	End If
End Sub

'Refreshes the UI. Should be called after modifying the tree state.
Public Sub Refresh
	For i = 0 To mCLV.Size - 1
		Dim item As CLVTreeItem = mCLV.GetValue(i)
		If ItemHasUI(item) Then
			UpdateItemUI(item)
		End If
	Next
	mCLV.Refresh
End Sub

Private Sub CreateItemUI (Item As CLVTreeItem)
	Dim pnl As B4XView = GetItemUI
	Item.InternalPanel.AddView(pnl, 0, 0, pnl.Width, pnl.Height)
	UpdateItemUI(Item)
End Sub

Private Sub UpdateItemUI (Item As CLVTreeItem)
	Dim indent As Int = GetItemIndent(Item)
	Dim pnl As B4XView = Item.InternalPanel.GetView(0)
	pnl.GetView(ARROW_INDEX).Left = indent + 5dip
	Dim image As B4XImageView = pnl.GetView(IMAGE_INDEX).Tag
	image.mBase.Left = indent + 30dip
	If Item.Image.IsInitialized Then
		image.Bitmap = Item.Image
	Else
		image.Clear
	End If
	Dim lbl As B4XView = pnl.GetView(LABEL_INDEX)
	lbl.Left = indent + 65dip
	lbl.Width = pnl.Width - lbl.Left
	lbl.Font = xui.CreateDefaultFont(lbl.Font.Size)
	lbl.TextColor = B4XPages.MainPage.GetLabelColor(Item.Tag.As(Tag).TagName)
	
'	Dim btn1 As B4XView = pnl.GetView(DRAGGER_INDEX)
'	btn1.Left = lbl.Width - 100dip
'	Dim btn2 As B4XView = pnl.GetView(TRASH_INDEX)
'	btn2.Left =  lbl.Width - 80dip
	
	XUIViewsUtils.SetTextOrCSBuilderToLabel(lbl, Item.Text)
	pnl.GetView(PANELTOUCH_INDEX).SetLayoutAnimated(0, 0, 0, indent + 65dip, pnl.Height)
	UpdateExpandIcon(Item)
End Sub

Private Sub GetItemUI As B4XView
	If UICache.Size > 0 Then
		Dim pnl As B4XView = UICache.Get(0)
		UICache.RemoveAt(0)
		Return pnl
	End If
	
	pnl = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, mCLV.AsView.Width, DefaultHeight)
	pnl.AddView(XUIViewsUtils.CreateB4XImageView.mBase, 0, pnl.Height / 2 - 10dip, 20dip, 20dip)
	pnl.GetView(ARROW_INDEX).Tag.As(B4XImageView).mBackgroundColor = xui.Color_Transparent
	pnl.GetView(ARROW_INDEX).Tag.As(B4XImageView).Bitmap = arrowbmp
	
	pnl.AddView(XUIViewsUtils.CreateB4XImageView.mBase, 0, pnl.Height / 2 - 15dip, 30dip, 30dip)
	pnl.GetView(IMAGE_INDEX).Tag.As(B4XImageView).mBackgroundColor = xui.Color_Transparent
	
	Dim lbl As B4XView = XUIViewsUtils.CreateLabel
	lbl.Font = mCLV.DesignerLabel.As(B4XView).Font
	lbl.TextColor = mCLV.DesignerLabel.As(B4XView).TextColor
	lbl.SetTextAlignment("CENTER", "LEFT")
	pnl.AddView(lbl, 0, 0, pnl.Width, pnl.Height)
	
	Dim Dragger As Label
	Dragger.Initialize("Drag")
	Dim drg As B4XView = Dragger ' XUIViewsUtils.CreateLabel
	'drg.Font = mCLV.DesignerLabel.As(B4XView).Font
	'drg.TextColor = xui.Color_Blue ' mCLV.DesignerLabel.As(B4XView).TextColor
	drg.TextColor = xui.Color_DarkGray ' mCLV.DesignerLabel.As(B4XView).TextColor
	drg.SetTextAlignment("CENTER", "RIGHT")
	drg.Font = xui.CreateMaterialIcons(mCLV.DesignerLabel.As(B4XView).Font.Size)
	'drg.Text = Chr(0xF0C9)
	drg.Text = Chr(0xE8D5)
	pnl.AddView(drg, pnl.Width - 60dip, 0, 30dip, pnl.Height)

	Dim Trash As Label
	Trash.Initialize("Trash")
	Dim trs As B4XView = Trash
	'trs.TextColor = xui.Color_Red
	trs.TextColor = xui.Color_Gray
	trs.SetTextAlignment("CENTER", "RIGHT")
	trs.Font = xui.CreateMaterialIcons(mCLV.DesignerLabel.As(B4XView).Font.Size)
	'trs.Text = Chr(0xF014)
	trs.Text = Chr(0xE92B)
	'pnl.AddView(trs, pnl.Width - 120dip, 0, 30dip, pnl.Height)
	pnl.AddView(trs, pnl.Width - 80dip, 0, 30dip, pnl.Height)
	
	Dim tp As B4XView = xui.CreatePanel("TouchPanel")
	pnl.AddView(tp, 0, 0, 0, 0)
	Return pnl
End Sub

#if B4J
Private Sub TouchPanel_MouseClicked (EventData As MouseEvent)
	EventData.Consume
#else
Private Sub TouchPanel_Click
#End If
	Dim item As CLVTreeItem = mCLV.GetValue(mCLV.GetItemFromView(Sender))
	If item.Children.Size = 0 Then Return
	If Not(item.InternalExpanded) Then
		ExpandImpl(item)
	Else
		CollapseImpl(item)
	End If
	mCLV.Refresh
End Sub

Private Sub GetItemIndent (Item As CLVTreeItem) As Int
	Dim Indent As Int
	Item = Item.Parent
	Do While Item <> Root
		Indent = Indent + IndentPerLevel
		Item = Item.Parent
	Loop
	Return Indent
End Sub

' =================================================================================================

'Private Sub ResizeItem (Index As Int, Collapse As Boolean)
'	Dim item As CLVItem = mCLV.GetRawListItem(Index)
'	Dim p As B4XView = item.Panel.GetView(0)
'	If p.NumberOfViews = 0 Or (item.Value Is ExpandableItemData) = False Then Return
'	Dim NewPanel As B4XView = xui.CreatePanel("")
'	MoveItemBetweenPanels(p, NewPanel)
'	Dim id As ExpandableItemData = item.Value
'	id.Expanded = Not(Collapse)
'	mCLV.sv.ScrollViewInnerPanel.AddView(NewPanel, 0, item.Offset, p.Width, id.ExpandedHeight)
'	Dim NewSize As Int
'	If Collapse Then NewSize = id.CollapsedHeight Else NewSize = id.ExpandedHeight
'	mCLV.ResizeItem(Index, NewSize)
'	NewPanel.SendToBack
'	Sleep(mCLV.AnimationDuration)
'	If p.Parent.IsInitialized Then
'		MoveItemBetweenPanels(NewPanel, p)
'	End If
'	NewPanel.RemoveViewFromParent
'End Sub

'Private Sub MoveItemBetweenPanels (Src As B4XView, Target As B4XView)
'	Do While Src.NumberOfViews > 0
'		Dim v As B4XView = Src.GetView(0)
'		v.RemoveViewFromParent
'		Target.AddView(v, v.Left, v.Top, v.Width, v.Height)
'	Loop
'End Sub

'Sub OpenItem (lbl As B4XView)
'	Dim index As Int = mCLV.GetItemFromView(lbl)
'	Dim data As ExpandableItemData = mCLV.GetValue(index)
'	ResizeItem(index, data.Expanded)
'End Sub

Private Sub PickItem (MouseY As Int, lbl As B4XView)
	Dim pnl As B4XView = mCLV.GetPanel(mCLV.GetItemFromView(lbl)).Parent
	pnl.GetView(0).SetColorAndBorder(xui.Color_Transparent, 3dip, 0xFF503ACD, 0)
	'pnl.GetView(0).SetColorAndBorder(xui.Color_White, 3dip, xui.Color_Transparent, 0)
	DragY = MouseY + lbl.Top + pnl.Top
	pnl.BringToFront
	DragTop = pnl.Top
End Sub

Private Sub MoveItem (MouseY As Int, lbl As B4XView)
	Dim pnl As B4XView = mCLV.GetPanel(mCLV.GetItemFromView(lbl)).Parent
	CheckScrollViewOffset(pnl)
	Dim clvY As Int = MouseY + lbl.Top + pnl.Top
	Dim delta As Int = clvY - DragY
	pnl.Top = DragTop + delta
End Sub

Private Sub DropItem (lbl As B4XView)
	Dim index As Int = mCLV.GetItemFromView(lbl)
	Dim pnl As B4XView = mCLV.GetPanel(index).Parent
	Dim Offset As Int = pnl.Top '+ pnl.Height / 2
	Dim NewIndex As Int = mCLV.FindIndexFromOffset(Offset)
	Dim UnderlyingItem As CLVItem = mCLV.GetRawListItem(NewIndex)
	If Offset - UnderlyingItem.Offset > UnderlyingItem.Size / 2 Then NewIndex = NewIndex + 1
	Dim ActualItem As B4XView = pnl.GetView(0)
	ActualItem.SetColorAndBorder(pnl.Color, 0dip, xui.Color_Black, 0)
	'ActualItem.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_Transparent, 0)
	Dim RawItem As CLVItem = mCLV.GetRawListItem(index)
	mCLV.RemoveAt(index)
	If NewIndex > index Then NewIndex = NewIndex - 1
	NewIndex = Max(0, Min(mCLV.Size, NewIndex))
	mCLV.InsertAt(NewIndex, ActualItem, RawItem.Value)
	mCLV.GetRawListItem(NewIndex).TextItem = RawItem.TextItem
End Sub

Private Sub CheckScrollViewOffset (pnl As B4XView)
	If pnl.Top < mCLV.sv.ScrollViewOffsetY Then
		mCLV.sv.ScrollViewOffsetY = Max(0, mCLV.sv.ScrollViewOffsetY - 10dip)
	Else If mCLV.sv.ScrollViewOffsetY + mCLV.sv.Height < pnl.Top + pnl.Height Then
		mCLV.sv.ScrollViewOffsetY = mCLV.sv.ScrollViewOffsetY + 10dip
	End If
End Sub

Private Sub Drag_MousePressed (EventData As MouseEvent)
	PickItem(EventData.Y, Sender)
End Sub

Private Sub Drag_MouseDragged (EventData As MouseEvent)
	Dim lbl As B4XView = Sender
	Do While True
		Wait For (lbl) Drag_MouseDragged (EventData As MouseEvent)
		MoveItem(EventData.Y, lbl)
	Loop
End Sub

Private Sub Drag_MouseReleased (EventData As MouseEvent)
	DropItem(Sender)
End Sub

Private Sub Trash_MouseClicked (EventData As MouseEvent)
	Dim index As Int = mCLV.GetItemFromView(Sender)
	'Dim pnl As B4XView = mCLV.GetPanel(index).Parent
	Select EventData.ClickCount
		Case 1
			Dim sf As Object = xui.Msgbox2Async("Delete element?", "Title", "Yes", "Cancel", "No", Null)
			Wait For (sf) Msgbox_Result (Result As Int)
			If Result = xui.DialogResponse_Positive Then
				'Log("Deleted!!!")
				'Log(Sender)
				mCLV.RemoveAt(index)
			End If
	End Select
End Sub