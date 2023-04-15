package dev.alnajjar.restaurant_system

import MethodResultWrapper
import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.app.ActivityManager.RunningTaskInfo
import android.app.PendingIntent
import android.app.PendingIntent.CanceledException
import android.content.Context
import android.content.Intent
import android.os.*
import android.os.Build.VERSION
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject


class MainActivity : FlutterActivity() {
    private val CHANNEL = "Alnajjar.dev.fultter/channel"
    private var methodResultWrapper: MethodResultWrapper? = null
    private val TAG = "Apex.TPP.Activity"

    companion object {
        @SuppressLint("StaticFieldLeak")
        lateinit var a: Activity

        @SuppressLint("StaticFieldLeak")
        lateinit var c: Context
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            methodResultWrapper = MethodResultWrapper(result)
            if (call.method == "txnSale") {
                var amount: String = call.argument("amount")!!
                TXN.Sale(amount)
            } else if (call.method == "printerNetwork") {
                val printerData = ArrayList<LIB.PrinterData?>()
                printerData.add(
                    LIB.PrinterData(
                        IsBold = false,
                        IsImage = true,
                        FontSize = 0,
                        Data = call.argument("invoice")!!
                    )
                )
                printerData.add(
                    LIB.PrinterData(
                        IsBold = false,
                        IsImage = false,
                        FontSize = 16,
                        Data = "\n\n\n\n"
                    )
                )
                TXN.Util_Print(printerData)
            } else {
                methodResultWrapper!!.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        a = this
        c = this.applicationContext
        if (LIB.clientInfo == null) {
            LIB.clientInfo = LIB.ClientInfo()
            try {
                val packageManager = a.packageManager
                val app = packageManager.getApplicationInfo(a.packageName, 0)
                LIB.clientInfo!!.ApplicationLabel =
                    packageManager.getApplicationLabel(app).toString()
                LIB.clientInfo!!.PackageName = a.packageName
                LIB.clientInfo!!.CalssName = a.intent.component!!.className
                LIB.clientInfo!!.PackageVersion =
                    packageManager.getPackageInfo(a.packageName, 0).versionName
            } catch (var7: Exception) {
                println(var7.message)
            }
        }
        val activityManager = c.getSystemService("activity" as String) as ActivityManager
        val tasks = activityManager.getRunningTasks(Int.MAX_VALUE)
        var counter = 0
        val var5: Iterator<*> = tasks.iterator()
        while (var5.hasNext()) {
            val task = var5.next() as RunningTaskInfo
            if (c.getPackageName().equals(task.baseActivity!!.packageName, ignoreCase = true)) {
                ++counter
                if (counter > 1) {
                    break
                }
            }
        }
        if (counter > 1) {
            Toast.makeText(c, "already running...", Toast.LENGTH_SHORT).show()
            Log.d("Apex.TPP.Activity", "onCreate(), Application already running")
            BringMyApplicationToFront(c)
            finishAndRemoveTask()
        }

        LIB.RegisterListener(object : LIB.ApexResultListener {
            override fun onSaleResult(saleResponse: LIB.SaleResponse?) {
                val response = HashMap<String, Any>()
                response["isApproved"] = saleResponse!!.IsApproved
                response["invoice"] = saleResponse.Invoice
                methodResultWrapper!!.success(response)
            }

            override fun onPrinterResult(printerResponse: LIB.PrinterResponse?) {
                val response = HashMap<String, Any>()
                response["code"] = printerResponse!!.Code
                methodResultWrapper!!.success(response)
            }

            override fun OnError(i: Int, s: String?) {
                val response = HashMap<String, Any>()
                response["isApproved"] = false
                response["invoice"] = ""
                methodResultWrapper!!.success(response)
            }
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val listener = LIB.GetListener()
        try {
            var mti: String?
            var description: String?
            if (data != null) {
                mti = data.action
                val dataStr = data.dataString
                description = data.getPackage()
                val type = data.type
                Log.d("Apex.TPP.Activity", "onActivityResult():      action = $mti")
                Log.d("Apex.TPP.Activity", "onActivityResult():     dataStr = $dataStr")
                Log.d(
                    "Apex.TPP.Activity",
                    "onActivityResult(): packageName = $description"
                )
                Log.d("Apex.TPP.Activity", "onActivityResult():        type = $type")
                val bundleExtra = data.extras
                if (bundleExtra != null) {
                    var reqJson: JSONObject? = JSONObject()
                    val var11: Iterator<*> = bundleExtra.keySet().iterator()
                    while (var11.hasNext()) {
                        val k = var11.next() as String
                        try {
                            val v = bundleExtra[k]
                            Log.e(
                                "Apex.TPP.Activity", "onActivityResult(): Bundle.[$k] = " + (v
                                    ?: "NULL")
                            )
                            if (v !is Bundle) {
                                reqJson!!.put(k, v)
                            } else {
                                val objVal = v as Bundle?
                                if (objVal != null) {
                                    val json = JSONObject()
                                    val var16: Iterator<*> = objVal.keySet().iterator()
                                    while (var16.hasNext()) {
                                        val eK = var16.next() as String
                                        val eV = objVal[eK]
                                        json.put(eK, eV)
                                        Log.e(
                                            "Apex.TPP.Activity",
                                            "onActivityResult(): Bundle.Extra.[$eK] = " + (eV
                                                ?: "NULL")
                                        )
                                    }
                                    reqJson!!.put(k, json)
                                }
                            }
                        } catch (var19: Exception) {
                            reqJson = null
                        }
                    }
                    Log.e(
                        "Apex.TPP.Activity",
                        "onActivityResult(): reqJson = " + reqJson.toString()
                    )
                }
            }
            if (listener == null) {
                Log.d("Apex.TPP.Activity", "onActivityResult: No Listener Registered")
                return
            }
            if (requestCode != 1982) {
                Log.d("Apex.TPP.Activity", "onActivityResult: Not for me, ignore it!")
                return
            }
            if (resultCode != requestCode) {
                Log.d("Apex.TPP.Activity", "onActivityResult: Result is Not OK!")
                listener.OnError(-2, "Canceled")
                return
            }
            if (data == null || data.extras == null) {
                Log.d("Apex.TPP.Activity", "onActivityResult: Not Data Received!")
                listener.OnError(-10, "No Data Received")
                return
            }
            mti = data.extras!!.getString("apex_tag_mti", "")
            var isApproved = data.extras!!
                .getBoolean("apex_tag_is_approved", false)
            description = ""
            when (mti) {
                "apex_txn_val_mti_sale" -> {
                    val amt = data.extras!!.getString("apex_tag_amount", "")
                    val pan = data.extras!!.getString("apex_tag_pan", "")
                    val Response = LIB.SaleResponse(data.extras)
                    listener.onSaleResult(Response)
                }
                "Util.Print" -> {
                    isApproved = true
                    val prtResponse = LIB.PrinterResponse(data.extras)
                    listener.onPrinterResult(prtResponse)
                }
                else -> {
                    listener.OnError(-11, "Invalid Response")
                    return
                }
            }
            if (!isApproved) {
                listener.OnError(-3, description)
            }
        } catch (var20: Exception) {
            listener!!.OnError(-1, var20.message)
        }
    }

    override fun onPause() {
        super.onPause()
    }

    override fun onPostResume() {
        super.onPostResume()
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun finish() {
        if (VERSION.SDK_INT >= 21) {
            super.finishAndRemoveTask()
        } else {
            super.finish()
        }
    }


    @SuppressLint("WrongConstant")
    private fun BringMyApplicationToFront(context: Context?) {
        try {
            val intent = context!!.packageManager.getLaunchIntentForPackage(context.packageName)
            intent!!.flags = 612368384
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, 0)
            pendingIntent.send()
            Log.d("Apex.TPP.Activity", "BringApplicationToFront() <<<<<<<<<<<<<<<<<<<<<<<<")
        } catch (var3: CanceledException) {
            var3.printStackTrace()
            Log.d("Apex.TPP.Activity", "Unable to BringApplicationToFront(), $var3")
        }
    }

    object TXN {
        private fun PostRequest(Action: String, category: String, b: Bundle?): Boolean {
            return try {
                val intent = Intent(Action)
                intent.addCategory(category)
                intent.putExtra("apex_lib_version", "1.0.0")
                if (LIB.clientInfo == null) {
                    false
                } else {
                    intent.putExtra("pkg_name", LIB.clientInfo!!.PackageName)
                    intent.putExtra("pkg_class", LIB.clientInfo!!.CalssName)
                    intent.putExtra("pkg_version", LIB.clientInfo!!.PackageVersion)
                    intent.putExtra("pkg_label", LIB.clientInfo!!.ApplicationLabel)
                    if (b != null) {
                        intent.putExtras(b)
                    }
                    intent.putExtra(
                        "APEX_LIB_TAG_RECEIVER",
                        LIB.generateParcelableReceiver(object : ResultReceiver(null as Handler?) {
                            override fun onReceiveResult(resultCode: Int, resultData: Bundle) {
                                val listener = LIB.GetListener()
                                val mHandler = Handler(Looper.getMainLooper())
                                mHandler.post(Runnable {
                                    try {
                                        if (listener == null) {
                                            Log.d(
                                                "Apex.TPP.Activity",
                                                "onActivityResult: No Listener Registered"
                                            )
                                            return@Runnable
                                        }
                                        if (resultData == null) {
                                            Log.d(
                                                "Apex.TPP.Activity",
                                                "onActivityResult: No Data Received!"
                                            )
                                            listener.OnError(-10, "No Data Received")
                                            return@Runnable
                                        }
                                        if (resultCode != 1982) {
                                            Log.d(
                                                "Apex.TPP.Activity",
                                                "onActivityResult: Not for me, ignore it!"
                                            )
                                            return@Runnable
                                        }
                                        val mti = resultData.getString("apex_tag_mti", "")
                                        var isApproved =
                                            resultData.getBoolean("apex_tag_is_approved", false)
                                        val description = ""
                                        when (mti) {
                                            "apex_txn_val_mti_sale" -> {
                                                val amt =
                                                    resultData.getString("apex_tag_amount", "")
                                                val pan = resultData.getString("apex_tag_pan", "")
                                                val Response = LIB.SaleResponse(resultData)
                                                listener.onSaleResult(Response)
                                            }
                                            "Util.Print" -> {
                                                isApproved = true
                                                val prtResponse = LIB.PrinterResponse(resultData)
                                                listener.onPrinterResult(prtResponse)
                                            }
                                            else -> {
                                                listener.OnError(-11, "Invalid Response")
                                                return@Runnable
                                            }
                                        }
                                    } catch (var10: Exception) {
                                        listener!!.OnError(-1, var10.message)
                                    }
                                })
                            }
                        })
                    )
                    a.startActivity(intent)
                    true
                }
            } catch (var4: Exception) {
                println(var4.message)
                false
            }
        }

        fun Sale(txnAmount: String?): Boolean {
            val b = Bundle()
            b.putString("apex_tag_mti", "apex_txn_val_mti_sale")
            b.putString("apex_tag_amount", txnAmount)
            return PostRequest(
                "apex.smartpos.action.THIRD_PARTY_PROXY",
                "apex.smartpos.category.TXN_SALE",
                b
            )
        }

        fun Util_Print(printerArrayData: ArrayList<LIB.PrinterData?>): Boolean {
            val jsonArray = JSONArray()
            val var2: Iterator<*> = printerArrayData.iterator()
            while (var2.hasNext()) {
                val data = var2.next() as LIB.PrinterData
                jsonArray.put(data.jSONObject)
            }
            val b = Bundle()
            b.putString("apex_tag_mti", "Util.Print")
            b.putString("apex_tag_printer_data", jsonArray.toString())
            Log.d("Apex.TPP.Activity", "apex_tag_printer_data: $jsonArray")
            return PostRequest(
                "apex.smartpos.action.THIRD_PARTY_PROXY",
                "apex.smartpos.category.TXN_SALE",
                b
            )
        }
    }

    object LIB {
        private var listener: ApexResultListener? = null
        var clientInfo: ClientInfo? = null
        fun RegisterListener(ResultListener: ApexResultListener?) {
            if (listener == null && ResultListener != null) {
                listener = ResultListener
            }
        }

        fun GetListener(): ApexResultListener? {
            return listener
        }

        fun generateParcelableReceiver(actualReceiver: ResultReceiver): ResultReceiver {
            val parcel = Parcel.obtain()
            actualReceiver.writeToParcel(parcel, 0)
            parcel.setDataPosition(0)
            val receiverForSending =
                ResultReceiver.CREATOR.createFromParcel(parcel) as ResultReceiver
            parcel.recycle()
            return receiverForSending
        }

        class PrinterData {
            var isBold = false
            var isImage = false
            var fontSize = 18
            var data = ""

            constructor() {
                isBold = false
                isImage = false
                fontSize = 18
                data = ""
            }

            constructor(IsBold: Boolean, IsImage: Boolean, FontSize: Int, Data: String) {
                isBold = IsBold
                isImage = IsImage
                fontSize = FontSize
                data = Data
            }

            val jSONObject: JSONObject
                get() {
                    val obj = JSONObject()
                    try {
                        obj.put("isBold", isBold)
                        obj.put("isImage", isImage)
                        obj.put("fontSize", fontSize)
                        obj.put("data", data)
                    } catch (var3: JSONException) {
                        Log.e(
                            "Apex.TPP.Activity",
                            "DefaultListItem.toString JSONException: " + var3.message
                        )
                    }
                    return obj
                }
        }

        class ClientInfo {
            var PackageName = ""
            var CalssName = ""
            var PackageVersion = ""
            var ApplicationLabel = ""
        }

        interface ApexResultListener {
            fun onSaleResult(saleResponse: SaleResponse?)
            fun onPrinterResult(printerResponse: PrinterResponse?)
            fun OnError(i: Int, s: String?)
        }

        class PrinterResponse(var b: Bundle?) {
            var Code = 0
            var Description = ""

            init {
                Code = b!!.getInt("apex_tag_error_code", 0)
                Description = b!!.getString("apex_tag_error_desc", "")
            }
        }

        class SaleResponse(var b: Bundle?) {
            var IsApproved = false
            var Amount = ""
            var RspCode = ""
            var RspText = ""
            var Rrn = ""
            var AuthCode = ""
            var Invoice = ""
            var CardSlot = ""
            var Pan = ""
            var Date = ""
            var Time = ""
            var Mid = ""
            var Tid = ""
            var TxnId = 0
            var TxnName = ""
            var IssuerName = ""
            var AcquirerName = ""
            var MerchantName = ""

            init {
                IsApproved = b!!.getBoolean("apex_tag_is_approved", false)
                Amount = b!!.getString("apex_tag_amount", "")
                RspCode = b!!.getString("apex_tag_rsp_code", "")
                RspText = b!!.getString("apex_tag_rsp_text", "")
                Rrn = b!!.getString("apex_tag_rrn", "")
                AuthCode = b!!.getString("apex_tag_auth_code", "")
                Invoice = b!!.getString("apex_tag_invoice", "")
                CardSlot = b!!.getString("apex_tag_card_slot", "0")
                Pan = b!!.getString("apex_tag_pan", "")
                Date = b!!.getString("apex_tag_date", "")
                Time = b!!.getString("apex_tag_time", "")
                Mid = b!!.getString("apex_tag_mid", "")
                Tid = b!!.getString("apex_tag_tid", "")
                TxnId = b!!.getInt("apex_tag_txn_type_id", 0)
                TxnName = b!!.getString("apex_tag_txn_name", "")
                IssuerName = b!!.getString("apex_tag_iss_name", "")
                AcquirerName = b!!.getString("apex_tag_acq_name", "")
                MerchantName = b!!.getString("apex_tag_merch_name", "")
            }
        }

        object APEX_RETVAL_TEXT {
            const val OK = "OK"
            const val FAILED = "Failed"
            const val CANCELED = "Canceled"
            const val DECLINED = "Declined"
            const val NO_DATA_RECEIVED = "No Data Received"
            const val INVALID_RESPONSE = "Invalid Response"
        }

        object APEX_RETVAL_CODE {
            const val OK = 0
            const val FAILED = -1
            const val CANCELED = -2
            const val DECLINED = -3
            const val NO_DATA_RECEIVED = -10
            const val INVALID_RESPONSE = -11
        }
    }
}

