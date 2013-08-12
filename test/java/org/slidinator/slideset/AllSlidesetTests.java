package org.slidinator.slideset;



import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.slidinator.slideset.ppt.TestPptHelper;

@RunWith(Suite.class)
@Suite.SuiteClasses({
    TestSlideSetFactory.class, 
    TestSlideSetTransformer.class,
    TestPptHelper.class})

public class AllSlidesetTests {
  //nothing
}