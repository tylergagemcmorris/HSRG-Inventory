using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("CPUPerformance")]
    public class CPUPerformance
    {

        [Key]
        public DateTime Time { get; set; }
        public float CPUUsage { get; set; }
    }
}