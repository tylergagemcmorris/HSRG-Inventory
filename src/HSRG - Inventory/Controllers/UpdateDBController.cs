using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.Entity;
using System.Web;
using System.Net;
using System.Web.Mvc;
using System.Threading;
using System.Threading.Tasks;
using HSRG___Inventory.Models;
using System.Reflection;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace HSRG___Inventory.Controllers
{
    public class UpdateDBController : AsyncController
    {
        // GET: UpdateDB
        public static string data { get; private set; }
        private Context db = new Context("InventoryDetails");

        public ActionResult DoWorkCompleted(string Datapoints)
        {
            data += Datapoints;
            return Content(Datapoints);
        }

        [HttpPost]
        public void UpdateTime (string result)
        {
            JToken token = JObject.Parse(result);
            var timetoupdate = db.TableTimestamps.First();
            string test = (string)token.SelectToken("Table");
            string timeValue = (string)token.SelectToken("Time");
            PropertyInfo propertyinfo = timetoupdate.GetType().GetProperty(test);
            propertyinfo.SetValue(timetoupdate, Convert.ChangeType(timeValue, propertyinfo.PropertyType), null);
            db.SaveChanges();
        }

        
        public void UpdateTablesAsync(string table)
        {
            
            string scriptpath = Server.MapPath("~/App_Data/DatabaseScripts/" + table + ".ps1");
            string DataSourcePath = Server.MapPath("~/App_Data/InventoryDetails.sqlite3");
            string InventoryList = Server.MapPath("~/App_Data/Max's Computer.txt");

            AsyncManager.OutstandingOperations.Increment();
            RunspaceConfiguration runspaceConfiguration = RunspaceConfiguration.Create();
            Runspace runspace = RunspaceFactory.CreateRunspace(runspaceConfiguration);

            runspace.Open();
            RunspaceInvoke scriptInvoker = new RunspaceInvoke(runspace);
            var pipeline = runspace.CreatePipeline();

            Command myCommand = new Command(scriptpath);
            myCommand.Parameters.Add("DataSource", DataSourcePath);
            myCommand.Parameters.Add("FilePath", InventoryList);
            pipeline.Commands.Add(myCommand);

            pipeline.Output.DataReady += (sender, e) =>
            {
                Thread.Sleep(1);
                string test = pipeline.Output.Read().ToString();
                if(pipeline.PipelineStateInfo.State.ToString() == "Completed")
                {
                    AsyncManager.Parameters["Output"] = "Completed";
                }
                else
                {
                    AsyncManager.Parameters["Output"] = pipeline.PipelineStateInfo.Reason.ToString();
                }
                AsyncManager.Parameters["Table"] = table;
                AsyncManager.Parameters["Time"] = DateTime.Now.ToString();

                AsyncManager.Finish();
            };

            pipeline.InvokeAsync();
            pipeline.Input.Close();
        }

        
        public ActionResult UpdateTablesCompleted(string Output, string Table, string Time)
        {
            var TotalResult = new OutputFromUpdateTables { Table = Table, Time = Time, Result = Output };
            string Results = JsonConvert.SerializeObject(TotalResult);
            return Content(Results);
        }

        public ActionResult UpdateTimeCompleted()
        {

            return Content("Done");
        }

        public ActionResult Test()
        {
            return View("~/Views/Performance/Test.cshtml");
        }

        public String example()
        {
            return data;
        }
    }
}