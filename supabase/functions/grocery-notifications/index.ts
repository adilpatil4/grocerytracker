import { serve } from "https://deno.land/std@0.192.0/http/server.ts";

serve(async (req) => {
  // ✅ CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*", // DO NOT CHANGE THIS
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "*" // DO NOT CHANGE THIS
      }
    });
  }
  
  try {
    const { userId, items, notificationType, userEmail, userName } = await req.json();

    // Prepare email content based on notification type
    let subject = "";
    let htmlContent = "";
    
    if (notificationType === "expiring_soon") {
      subject = "🍎 GrocerEase: Items Expiring Soon!";
      
      const itemsList = items.map(item => 
        `<li><strong>${item.name}</strong> - Expires ${item.expiration_date} (${item.days_until_expiration} days left)</li>`
      ).join('');
      
      htmlContent = `
        <html>
          <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
              <h2 style="color: #4CAF50;">🍎 Hello ${userName}!</h2>
              <p>Some of your grocery items are expiring soon. Here's what needs your attention:</p>
              <ul style="background-color: #f9f9f9; padding: 15px; border-left: 4px solid #ff9800;">
                ${itemsList}
              </ul>
              <p><strong>💡 Pro tip:</strong> Use these items first or consider freezing them if possible!</p>
              <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
              <p style="font-size: 12px; color: #666;">
                This notification was sent because you have email notifications enabled in GrocerEase.
                <br>Happy grocery managing! 🛒
              </p>
            </div>
          </body>
        </html>
      `;
    } else if (notificationType === "expired") {
      subject = "⚠️ GrocerEase: Expired Items Alert";
      
      const itemsList = items.map(item => 
        `<li><strong>${item.name}</strong> - Expired ${item.expiration_date}</li>`
      ).join('');
      
      htmlContent = `
        <html>
          <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
              <h2 style="color: #f44336;">⚠️ Hello ${userName}!</h2>
              <p>These grocery items have expired and should be checked:</p>
              <ul style="background-color: #ffebee; padding: 15px; border-left: 4px solid #f44336;">
                ${itemsList}
              </ul>
              <p><strong>🗑️ Safety first:</strong> Please check these items and dispose of any that are no longer safe to consume.</p>
              <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
              <p style="font-size: 12px; color: #666;">
                This notification was sent because you have email notifications enabled in GrocerEase.
                <br>Stay safe and healthy! 🛒
              </p>
            </div>
          </body>
        </html>
      `;
    }

    // Send email using Resend API
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'onboarding@resend.dev',
        to: [userEmail],
        subject: subject,
        html: htmlContent,
      }),
    });

    if (!resendResponse.ok) {
      throw new Error(`Resend API error: ${resendResponse.status}`);
    }

    const emailResult = await resendResponse.json();

    return new Response(JSON.stringify({
      success: true,
      message: `${notificationType} notification sent successfully`,
      emailId: emailResult.id,
      itemsCount: items.length
    }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // DO NOT CHANGE THIS
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message,
      success: false
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*" // DO NOT CHANGE THIS
      }
    });
  }
});