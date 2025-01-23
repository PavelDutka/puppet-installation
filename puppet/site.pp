# Assign team to their specific configuration
node 'projects-*' { 
    include projects 
} 
 
node 'products-*' { 
    include products 
} 
 
node 'projects-vasek' { 
    include home_office 
} 
 
node 'products-filip' { 
    include home_office 
} 
 
node default { 
    include common::config 
}