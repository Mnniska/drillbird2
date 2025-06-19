extends PanelContainer

@onready var continueButton:button_script = $Button_Continue

func IsButton():
	return continueButton.isButton()

func SetSelected(selected:bool): 
	continueButton.SetSelected(selected)

func isButton():
	return true

func AttemptToPurchase():
	return false
