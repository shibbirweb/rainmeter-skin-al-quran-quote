[Variables]
; Which quote window the settings panel is currently editing. A window's gear writes its own config name
; here (via !WriteKeyValue) and reloads the panel, so the one shared settings panel targets whichever window
; opened it. The panel derives that window's @Resources path from this name plus #SKINSPATH#. Default is the
; base window (AlQuranQuote). Managed at runtime; do not hand-edit.
TargetConfig=AlQuranQuote
