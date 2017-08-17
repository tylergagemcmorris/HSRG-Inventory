﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.Entity;
using System.Web;
using System.Net;
using System.Web.Mvc;
using HSRG___Inventory.Models;
using System.Reflection;

namespace HSRG___Inventory.Controllers
{
    public class HomeController : Controller
    {
        private Context db = new Context("InventoryDetails");

        public ActionResult Index(string TypeFilter, string SortBy)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.InventoryDetail).GetProperties();
            ViewBag.properties = properties;

            ViewBag.SortBy = SortBy;
            ViewBag.ShowType = TypeFilter;
            var details = from s in db.InventoryDetails
                          select s;
            switch (TypeFilter)
            {
                case "Computers":
                    details = details.Where(s => s.ComputerID == "HSRG-100H2");
                    break;
                case "Servers":
                    details = details.Where(s => s.ComputerID == "HSRG-100H3");
                    break;
                default:
                    break;
            }

            return View(details.ToList());
        }



        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            InventoryDetail InventoryDetails = db.InventoryDetails.Find(id);
            if (InventoryDetails == null)
            {
                return HttpNotFound();
            }

            ViewBag.id = id;

            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.BIOSInformation).GetProperties();
            ViewBag.properties = properties;
            //var BIOSInfo = db.BIOSInformation.First(s => s.ComputerID == id);

            return View();
        }

        [ChildActionOnly]
        public ActionResult PartialBios(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.BIOSInformation).GetProperties();
            ViewBag.properties = properties;

            return PartialView("~/Views/Table/BiosInformation.cshtml", db.BIOSInformation.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialMemory(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.MemoryInformation).GetProperties();
            ViewBag.properties = properties;

            return PartialView("~/Views/Table/MemoryInformation.cshtml", db.MemoryInformation.First(s => s.ComputerID == id));
        }

        [ChildActionOnly]
        public ActionResult PartialSystem(string id)
        {
            PropertyInfo[] properties = typeof(HSRG___Inventory.Models.SystemInformation).GetProperties();
            ViewBag.properties = properties;

            return PartialView("~/Views/Table/SystemInformation.cshtml", db.SystemInformation.First(s => s.ComputerID == id));
        }
    }
}