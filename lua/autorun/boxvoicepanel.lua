AddCSLuaFile()

if SERVER then return end

print("Box Voice Panels Loaded")

local Enabled = CreateClientConVar("cleanvoice_enable", 1, true, false, "Enables or disables clean voice panels")
local FadeRate = CreateClientConVar("cleanvoice_faderate", 100, true, false, "The speed at which the panels fade")
local RightMargin = CreateClientConVar("cleanvoice_margin_right", 0, true, false, "How much space between the right side of the panels and the screen")
local BoxMargins = CreateClientConVar("cleanvoice_box_gaps", 0, true, false, "How much space between the panels")


local Height = ScrH()/1.5
local Width = ScrW()/7

local Frame = nil

local VoicePanels = {}
local ShouldFade = {}
local FadeTimestamp = {}

local function ColorVol(Ply)

	if not Ply:IsValid() then return Color(0,0,0,240) end

	local TeamCol = team.GetColor(Ply:Team())

	local Vol = Ply:VoiceVolume()*10 -- 0 black, 1 full team colour

	local R = TeamCol.r*Vol
	local G = TeamCol.g*Vol
	local B = TeamCol.b*Vol

	return Color(R,G,B,240)

end



hook.Add("PlayerStartVoice", "StartBoxVoicePanels", function(Ply)

	if not Enabled:GetFloat() == 0 then return end --Do nothing if not enabled

	if not Frame then

		Frame = vgui.Create( "DPanel" )
		Frame:SetPos( (ScrW()-Width+1) - RightMargin:GetFloat(), ScrH()/2-(Height/2) )
		Frame:SetSize(Width, Height)
		Frame:DockPadding( 0, 0, 0, 0)
		Frame:SetPaintBackground(false)

		cvars.AddChangeCallback("cleanvoice_margin_right", function(Name, OldVal, NewVal)
			Frame:SetPos( (ScrW()-Width+1) - NewVal, ScrH()/2-(Height/2) )
		end)

	end



	ShouldFade[Ply] = false

	if VoicePanels[Ply] then return false end

	if not IsValid(Ply) then
		VoicePanels[Ply]:Remove()
		VoicePanels[Ply] = nil
	end

	local Panel = vgui.Create("DPanel", Frame)
	Panel:Dock(BOTTOM)
	Panel:SetHeight(ScrH()/20)
	Panel:DockMargin( 0, BoxMargins:GetFloat(), 0, 0)

	Panel.Paint = function( self, w, h )

		if not IsValid(Ply) then
			self:Remove()
			return
		end

		local Alpha = 255

		if ShouldFade[Ply] and not (Ply:VoiceVolume() > 1) then --Panel sometimes shows colour behind partially faded avatar
			Alpha = 255 - ((CurTime() - FadeTimestamp[Ply])*FadeRate:GetFloat())
		end

		if Alpha < 0 then
			VoicePanels[Ply]:Remove()
			VoicePanels[Ply] = nil
		end

		--draw.RoundedBox( 0, 0, 0, w, h, Color( 0, Ply:VoiceVolume() * 255, 0, 225 ) )
		draw.RoundedBox( 0, 0, 0, w, h, ColorVol(Ply) )
		Panel:SetAlpha(Alpha)

	end

	local Avatar = vgui.Create( "AvatarImage", Panel )
	Avatar:Dock(LEFT)
	Avatar:SetWidth(Panel:GetTall())
	Avatar:SetPlayer( Ply, 64)


	local Label = vgui.Create( "DLabel", Panel)
	Label:SetFont( "GModNotify" )
	Label:Dock( FILL )
	Label:DockMargin( 8, 0, 0, 0 )
	Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	Label:SetText(Ply:Nick())

	VoicePanels[Ply] = Panel

	return false

end)

hook.Add("PlayerEndVoice", "EndBoxVoicePanels", function(Ply)
	ShouldFade[Ply] = true
	FadeTimestamp[Ply] = CurTime()
end)
