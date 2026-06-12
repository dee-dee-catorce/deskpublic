// Remember to include System and System.Runtime.InteropServices
using Godot;
using System;
using System.Runtime.InteropServices;

public partial class TransparentWindow : Node { // Autoloaded

    // SetWindowLong() modifies a specific flag value associated with a window.
    // We pass the window handle, the index of the property, and the flags the property will have
    [DllImport("user32.dll")]
    private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

    // This is the index of the property we want to modify
    private const int GwlExStyle = -20;

    // The flags we want to set
    private const int WsExLayered = 0x80000;         // Makes the window "layered"
    private const int WsExTransparent = 0x20;       // Makes the window "clickable through"
    // check https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles 
    // This is the variable containing the window handle
    private IntPtr _hWnd;
  //  private bool isGb;
    public override void _Ready()
    {
        // We store the window handle
        _hWnd = (IntPtr)DisplayServer.WindowGetNativeHandle(DisplayServer.HandleType.WindowHandle, GetWindow().GetWindowId());
        
        // We can set the properties already from here
        SetWindowLong(_hWnd, GwlExStyle, WsExLayered );

        SetClickThrough(true);
       // Node glob = GetNode("root/gbData");
//        isGb = (bool)glob.Get("devMode");
    }

    // This function sets the property of being clickable or not, we will call this function from the mouse detection 
    public void SetClickThrough(bool clickthrough)
    {
        if (clickthrough)
        {
            // We set the window as layered and click-through
            SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent);
            
            Engine.MaxFps  = 30;
        }
        else
        {
            // We only set the window as layered, so it will be clickable
            SetWindowLong(_hWnd, GwlExStyle, WsExLayered);
            Engine.MaxFps  = 60;
        }
    }

    /* What is a layered window? 
     * In the Windows API, a layered window is a special type of window that offers several
     * advantages over standard windows:
     * 
     * Transparency: Layered windows can be partially transparent, allowing the content of underlying windows
     * to show through. This can be achieved using either color keying, where a specific color in the window
     * is transparent, or alpha blending, where the window's opacity is specified for each pixel.
     *
     * Complex Shapes: Layered windows can have complex shapes that are not limited by rectangular regions.
     * This is achieved by defining a custom region, allowing for more visually appealing or functional window designs.
     *
     * Animation: Layered windows can be animated smoothly without the visual artifacts
     * that can occur with standard windows due to region updates. This is because the system automatically manages
     * the composition of layered windows with underlying elements.
     */
}