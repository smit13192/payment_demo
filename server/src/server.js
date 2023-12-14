const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const crypto = require('crypto');
const Razorpay = require("razorpay");
dotenv.config();

const app = express();
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(cors());

var instance = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
});

app.post("/create-order", async (req, res) => {
    const { amount } = req.body;
    try {
        var options = {
            amount: amount * 100,
            currency: "INR",
        };
        const order = await instance.orders.create(options);
        res.status(200).json({
            success: true,
            data: order
        })
    } catch (e) {
        res.status(400).json({
            success: false,
            message: e.message,
        })
    }
})

app.post("/payment", async (req, res) => {
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature } = req.body;
    try {
        const body = razorpay_order_id + "|" + razorpay_payment_id;
        const generated_signature = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(body.toString())
            .digest('hex');
        console.log(generated_signature);
        console.log(razorpay_signature);

        if (generated_signature === razorpay_signature) {
            console.log(true);
            return res.status(200).json({ success: true })
        }
        res.status(400).json({ success: false })
    } catch (e) {
        res.status(400).json({
            success: false,
            message: e.message,
        })
    }
})

app.listen(5000, () => {
    console.log(`Server start port 5000`);
})