// const express = require('express');
// const mongoose = require('mongoose');
// const bcrypt = require('bcrypt')
// const cors = require('cors');
// const nodemailer = require('nodemailer');
// const crypto = require('crypto');
// require('dotenv').config();

// const User = require('../password_manager/lib/models/User');

// const app = express();
// const PORT = process.env.PORT || 3000;

// // Middleware
// app.use(cors());
// app.use(express.json());

// // // In-memory storage for OTPs (use Redis/Database in production)
// // const otpStorage = new Map();
// // const userSessions = new Map();

// // // Email transporter configuration
// // const transporter = nodemailer.createTransport({
// //   host: process.env.EMAIL_HOST,
// //   port: process.env.EMAIL_PORT,
// //   secure: false,
// //   auth: {
// //     user: process.env.EMAIL_USER,
// //     pass: process.env.EMAIL_PASS,
// //   },
// // });

// // // Generate 6-digit OTP
// // function generateOTP() {
// //   //return Math.floor(100000 + Math.random() * 900000).toString();
// //   const n = crypto.randomInt(0, 1000000); // 0..999999
// //   return n.toString().padStart(6, '0');   // 固定6位，前导0补齐
// // }

// // // Send OTP via email
// // async function sendOTPEmail(email, otp) {
// //   const mailOptions = {
// //     from: process.env.EMAIL_FROM,
// //     to: email,
// //     subject: '2FA Verification Code',
// //     html: `
// //       <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
// //         <h2 style="color: #333;">Two-Factor Authentication</h2>
// //         <p>Your verification code is:</p>
// //         <div style="background-color: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
// //           <span style="font-size: 32px; font-weight: bold; color: #007bff; letter-spacing: 4px;">${otp}</span>
// //         </div>
// //         <p style="color: #666;">This code will expire in 10 minutes.</p>
// //         <p style="color: #666;">If you didn't request this code, please ignore this email.</p>
// //       </div>
// //     `,
// //   };

// //   try {
// //     await transporter.sendMail(mailOptions);
// //     return true;
// //   } catch (error) {
// //     console.error('Email sending failed:', error);
// //     return false;
// //   }
// // }

// // // Routes

// // // Health check
// // app.get('/health', (req, res) => {
// //   res.json({ status: 'OK', message: '2FA Backend is running' });
// // });

// // // Request OTP
// // app.post('/api/request-otp', async (req, res) => {
// //   try {
// //     const { email } = req.body;

// //     if (!email) {
// //       return res.status(400).json({ error: 'Email is required' });
// //     }

// //     // Generate OTP
// //     const otp = generateOTP();
// //     const sessionId = crypto.randomUUID();
    
// //     // Store OTP with expiration (10 minutes)
// //     otpStorage.set(sessionId, {
// //       email,
// //       otp,
// //       expires: Date.now() + 10 * 60 * 1000, // 10 minutes
// //       attempts: 0,
// //     });

// //     // Send OTP via email
// //     const emailSent = await sendOTPEmail(email, otp);

// //     if (!emailSent) {
// //       return res.status(500).json({ error: 'Failed to send OTP email' });
// //     }

// //     res.json({
// //       success: true,
// //       message: 'OTP sent to your email',
// //       sessionId,
// //     });
// //   } catch (error) {
// //     console.error('Request OTP error:', error);
// //     res.status(500).json({ error: 'Internal server error' });
// //   }
// // });

// // // Verify OTP
// // app.post('/api/verify-otp', (req, res) => {
// //   try {
// //     const { sessionId, otp } = req.body;

// //     if (!sessionId || !otp) {
// //       return res.status(400).json({ error: 'Session ID and OTP are required' });
// //     }

// //     const otpData = otpStorage.get(sessionId);

// //     if (!otpData) {
// //       return res.status(400).json({ error: 'Invalid or expired session' });
// //     }

// //     // Check expiration
// //     if (Date.now() > otpData.expires) {
// //       otpStorage.delete(sessionId);
// //       return res.status(400).json({ error: 'OTP has expired' });
// //     }

// //     // Check attempts limit
// //     if (otpData.attempts >= 3) {
// //       otpStorage.delete(sessionId);
// //       return res.status(400).json({ error: 'Too many failed attempts' });
// //     }

// //     // Verify OTP
// //     if (otpData.otp !== otp) {
// //       otpData.attempts++;
// //       return res.status(400).json({ 
// //         error: 'Invalid OTP',
// //         attemptsLeft: 3 - otpData.attempts 
// //       });
// //     }

// //     // OTP verified successfully
// //     otpStorage.delete(sessionId);
    
// //     // Generate auth token (in production, use JWT)
// //     const authToken = crypto.randomUUID();
// //     userSessions.set(authToken, {
// //       email: otpData.email,
// //       verified: true,
// //       timestamp: Date.now(),
// //     });

// //     res.json({
// //       success: true,
// //       message: 'OTP verified successfully',
// //       authToken,
// //       user: { email: otpData.email },
// //     });
// //   } catch (error) {
// //     console.error('Verify OTP error:', error);
// //     res.status(500).json({ error: 'Internal server error' });
// //   }
// // });

// // // Verify auth token
// // app.get('/api/verify-token/:token', (req, res) => {
// //   const { token } = req.params;
// //   const session = userSessions.get(token);

// //   if (!session) {
// //     return res.status(401).json({ error: 'Invalid or expired token' });
// //   }

// //   res.json({
// //     success: true,
// //     user: { email: session.email },
// //     verified: session.verified,
// //   });
// // });

// // // Start server
// // app.listen(PORT, () => {
// //   console.log(`Server running on http://localhost:${PORT}`);
// // });

// // 临时存 OTP（生产环境用 Redis/数据库）
// let otpStore = {};

// /// ===== 注册新用户 =====
// app.post('/api/register', async (req, res) => {
//   const { email, password } = req.body;

//   try {
//     const existing = await User.findOne({ email });
//     if (existing) {
//       return res.status(400).json({ success: false, message: 'Email already registered' });
//     }

//     const passwordHash = await bcrypt.hash(password, 10);

//     const user = new User({ email, passwordHash });
//     await user.save();

//     res.json({ success: true, message: 'User registered successfully' });
//   } catch (err) {
//     res.status(500).json({ success: false, message: 'Server error' });
//   }
// });

// /// ===== 请求 OTP =====
// app.post('/api/request-otp', async (req, res) => {
//   const { email, password } = req.body;

//   try {
//     // 查找用户
//     const user = await User.findOne({ email });

//     if (!user) {
//       // 如果用户不存在 → 自动注册
//       const passwordHash = await bcrypt.hash(password, 10);
//       user = new User({ email, passwordHash });
//       await user.save();
//       console.log(`New User Registered: ${email}`);
//     } else {
//       // 如果存在 → 验证密码
//       const isMatch = await bcrypt.compare(password, user.passwordHash);
//       if (!isMatch) {
//         return res.status(401).json({ success: false, message: 'Invalid password' });
//       }
//     }

//     // // 验证密码
//     // const isMatch = await bcrypt.compare(password, user.passwordHash);
//     // if (!isMatch) return res.status(401).json({ success: false, message: 'Invalid password' });

//     // 生成 OTP
//     const otp = Math.floor(100000 + Math.random() * 900000).toString();

//     // 保存 OTP
//     otpStore[email] = { otp, expiresAt: Date.now() + 10 * 60 * 1000 }; // 5分钟有效

//     // 发送邮件
//     const transporter = nodemailer.createTransport({
//       host: process.env.EMAIL_HOST,
//       port: process.env.EMAIL_PORT,
//       secure: false,
//       auth: {
//         user: process.env.EMAIL_USER,
//         pass: process.env.EMAIL_PASS,
//       },
//     });

//     await transporter.sendMail({
//       from: process.env.EMAIL_FROM,
//       to: email,
//       subject: 'Your OTP Code',
//       text: `Your OTP code is ${otp}. It is valid for 10 minutes.`,
//     });

//     res.json({ success: true, message: 'OTP sent to email' });
//   } catch (err) {
//     res.status(500).json({ success: false, message: 'Server error' });
//   }
// });

// /// ===== 验证 OTP =====
// app.post('/api/verify-otp', (req, res) => {
//   const { email, otp } = req.body;

//   const session = otpStore[email];
//   if (!session) return res.status(400).json({ success: false, message: 'No OTP requested' });

//   if (Date.now() > session.expiresAt) {
//     return res.status(400).json({ success: false, message: 'OTP expired' });
//   }

//   if (otp !== session.otp) {
//     return res.status(400).json({ success: false, message: 'Invalid OTP' });
//   }

//   // OTP 正确 → 登录成功
//   delete otpStore[email]; // 删除 OTP
//   res.json({ success: true, message: 'OTP verified, login success' });
// });

// /// ===== 启动服务 =====
// mongoose
//   .connect('mongodb://localhost:27017/tfa_demo')
//   .then(() => {
//     app.listen(3000, () => console.log('Server running on port 3000'));
//   })
//   .catch((err) => console.error(err));

const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const cors = require('cors');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// CORS Configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// In-memory OTP storage (consider Redis for production)
let otpStore = {};

// ===== User Schema Definition =====
// Define the schema directly in server.js since external model path may cause issues
const userSchema = new mongoose.Schema({
  email: { 
    type: String, 
    required: true, 
    unique: true,
    lowercase: true,
    trim: true
  },
  passwordHash: { 
    type: String, 
    required: true 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  }
});

const User = mongoose.model('User', userSchema);

// ===== Health Check =====
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: '2FA Backend is running',
    timestamp: new Date().toISOString()
  });
});

// ===== Register New User =====
app.post('/api/register', async (req, res) => {
  const { email, password } = req.body;

  // Validation
  if (!email || !password) {
    return res.status(400).json({ 
      success: false, 
      message: 'Email and password are required' 
    });
  }

  if (password.length < 6) {
    return res.status(400).json({ 
      success: false, 
      message: 'Password must be at least 6 characters' 
    });
  }

  try {
    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email already registered' 
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = new User({ 
      email: email.toLowerCase(), 
      passwordHash 
    });
    await user.save();

    console.log(`✅ User registered: ${email}`);
    res.json({ 
      success: true, 
      message: 'User registered successfully' 
    });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Server error during registration' 
    });
  }
});

// ===== Request OTP (Login with 2FA) =====
app.post('/api/request-otp', async (req, res) => {
  const { email, password } = req.body;

  // Validation
  if (!email || !password) {
    return res.status(400).json({ 
      success: false, 
      message: 'Email and password are required' 
    });
  }

  try {
    // Find existing user
    let user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      // Option 1: Auto-register new user (current behavior)
      // Option 2: Return error (more secure - uncomment below)
      
      // return res.status(404).json({ 
      //   success: false, 
      //   message: 'User not found. Please register first.' 
      // });

      // Auto-register new user
      const passwordHash = await bcrypt.hash(password, 10);
      user = new User({ 
        email: email.toLowerCase(), 
        passwordHash 
      });
      await user.save();
      console.log(`✅ New user auto-registered: ${email}`);
    } else {
      // Verify password for existing user
      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        return res.status(401).json({ 
          success: false, 
          message: 'Invalid password' 
        });
      }
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore[email.toLowerCase()] = { 
      otp, 
      expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
      attempts: 0
    };

    // Configure email transporter
    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST,
      port: parseInt(process.env.EMAIL_PORT),
      secure: false, // true for 465, false for other ports
      auth: { 
        user: process.env.EMAIL_USER, 
        pass: process.env.EMAIL_PASS 
      },
    });

    // Send OTP email with HTML template
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: email,
      subject: '🔐 Your Two-Factor Authentication Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #333; text-align: center;">Two-Factor Authentication</h2>
          <p style="font-size: 16px; color: #666;">Hello,</p>
          <p style="font-size: 16px; color: #666;">Your verification code is:</p>
          <div style="background-color: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px;">
            <span style="font-size: 36px; font-weight: bold; color: #007bff; letter-spacing: 8px;">${otp}</span>
          </div>
          <p style="font-size: 14px; color: #999;">This code will expire in 10 minutes.</p>
          <p style="font-size: 14px; color: #999;">If you didn't request this code, please ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #999; text-align: center;">This is an automated message, please do not reply.</p>
        </div>
      `,
      text: `Your OTP code is ${otp}. It is valid for 10 minutes.`
    });

    console.log(`📧 OTP sent to ${email}: ${otp}`); // Remove in production
    res.json({ 
      success: true, 
      message: 'OTP sent to your email',
      email: email, // Send back for verification screen
      sessionId: Date.now().toString()
    });
  } catch (err) {
    console.error('❌ Request OTP error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to send OTP. Please check email configuration.' 
    });
  }
});

// ===== Verify OTP =====
app.post('/api/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  // Validation
  if (!email || !otp) {
    return res.status(400).json({ 
      success: false, 
      message: 'Email and OTP are required' 
    });
  }

  const normalizedEmail = email.toLowerCase();
  const session = otpStore[normalizedEmail];

  if (!session) {
    return res.status(400).json({ 
      success: false, 
      message: 'No OTP requested for this email' 
    });
  }

  // Check expiration
  if (Date.now() > session.expiresAt) {
    delete otpStore[normalizedEmail];
    return res.status(400).json({ 
      success: false, 
      message: 'OTP expired. Please request a new one.' 
    });
  }

  // Check attempts limit
  if (session.attempts >= 3) {
    delete otpStore[normalizedEmail];
    return res.status(400).json({ 
      success: false, 
      message: 'Too many failed attempts. Please request a new OTP.' 
    });
  }

  // Verify OTP
  if (otp !== session.otp) {
    session.attempts++;
    return res.status(400).json({ 
      success: false, 
      message: 'Invalid OTP',
      attemptsLeft: 3 - session.attempts
    });
  }

  // OTP verified successfully
  delete otpStore[normalizedEmail];
  
  // Get user info
  const user = await User.findOne({ email: normalizedEmail });

  
// inside OTP verification success
const token = jwt.sign(
  { userId: user._id, email: user.email },
  process.env.JWT_SECRET || 'your-secret-key',
  { expiresIn: '1h' }
);
  
  console.log(`✅ OTP verified for ${email}`);
  res.json({ 
    success: true, 
    message: 'OTP verified successfully. Login complete!',
    authToken: token,
    user: {
      email: user.email,
      userId: user._id
    }
  });
});

// ===== Get User Info (Optional - for testing) =====
app.get('/api/user/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email.toLowerCase() });
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }
    res.json({ 
      success: true, 
      user: { 
        email: user.email, 
        createdAt: user.createdAt 
      } 
    });
  } catch (err) {
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

// ===== Error Handling Middleware =====
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ 
    success: false, 
    message: 'Internal server error' 
  });
});

// ===== Connect to MongoDB and Start Server =====
mongoose
  .connect('mongodb://127.0.0.1:27017/tfa_demo', {
    useNewUrlParser: true,
    useUnifiedTopology: true
  })
  .then(() => {
    console.log('✅ MongoDB connected successfully');
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📧 Email configured: ${process.env.EMAIL_USER}`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });